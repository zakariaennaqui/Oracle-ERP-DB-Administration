-- Scénario 2 : Trigger de mise à jour automatique du stock

CREATE OR REPLACE TRIGGER trg_after_insert_ligne
AFTER INSERT ON LIGNE_COMMANDE
FOR EACH ROW
DECLARE
    v_nouveau_stock NUMBER;
BEGIN
    -- Diminuer le stock
    UPDATE PRODUIT 
    SET quantite_stock = quantite_stock - :NEW.quantite
    WHERE id_produit = :NEW.id_produit
    RETURNING quantite_stock INTO v_nouveau_stock;
    
    -- Enregistrer le mouvement de stock
    INSERT INTO STOCK_MOUVEMENT (id_mouvement, type_mouvement, quantite, id_produit, motif)
    VALUES (seq_mouvement.NEXTVAL, 'SORTIE', :NEW.quantite, :NEW.id_produit, 
            'Vente commande ' || :NEW.id_commande);
    
    -- Alerte si stock faible
    IF v_nouveau_stock < (SELECT seuil_alerte FROM PRODUIT WHERE id_produit = :NEW.id_produit) THEN
        INSERT INTO AUDIT_LOG (id_log, utilisateur, action, table_concernee, details)
        VALUES (seq_audit.NEXTVAL, USER, 'ALERTE_STOCK', 'PRODUIT',
                'Stock faible (' || v_nouveau_stock || ') pour produit ID: ' || :NEW.id_produit);
    END IF;
END;
/