-- Scénario 1 : Procédure pour passer une commande

CREATE OR REPLACE PROCEDURE passer_commande (
    p_id_client NUMBER,
    p_id_user NUMBER,
    p_lignes SYS_REFCURSOR
) AS
    v_id_commande NUMBER;
    v_produit_id NUMBER;
    v_quantite NUMBER;
    v_prix NUMBER;
    v_total_commande NUMBER := 0;
    v_stock_actuel NUMBER;
BEGIN
    -- Créer la commande
    SELECT seq_commande.NEXTVAL INTO v_id_commande FROM dual;
    
    INSERT INTO COMMANDE (id_commande, id_client, id_user, date_commande)
    VALUES (v_id_commande, p_id_client, p_id_user, SYSDATE);
    
    -- Traiter chaque ligne de commande
    LOOP
        FETCH p_lignes INTO v_produit_id, v_quantite;
        EXIT WHEN p_lignes%NOTFOUND;
        
        -- Vérifier le stock
        SELECT quantite_stock INTO v_stock_actuel 
        FROM PRODUIT 
        WHERE id_produit = v_produit_id;
        
        IF v_stock_actuel < v_quantite THEN
            RAISE_APPLICATION_ERROR(-20001, 'Stock insuffisant pour le produit ID: ' || v_produit_id);
        END IF;
        
        -- Récupérer le prix
        SELECT prix_unitaire INTO v_prix 
        FROM PRODUIT 
        WHERE id_produit = v_produit_id;
        
        -- Insérer la ligne
        INSERT INTO LIGNE_COMMANDE (id_ligne, id_commande, id_produit, quantite, prix_unitaire)
        VALUES (seq_ligne.NEXTVAL, v_id_commande, v_produit_id, v_quantite, v_prix);
        
        v_total_commande := v_total_commande + (v_quantite * v_prix);
    END LOOP;
    
    -- Mettre à jour le total
    UPDATE COMMANDE SET total = v_total_commande WHERE id_commande = v_id_commande;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Commande ' || v_id_commande || ' créée avec succès.');
END;
/