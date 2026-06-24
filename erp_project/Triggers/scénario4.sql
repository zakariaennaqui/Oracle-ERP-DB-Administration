-- Scénario 4 : Trigger d'audit de sécurité

CREATE OR REPLACE TRIGGER trg_audit_produit
AFTER INSERT OR UPDATE OR DELETE ON PRODUIT
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
    ELSE
        v_action := 'DELETE';
    END IF;
    
    INSERT INTO AUDIT_LOG (id_log, utilisateur, action, table_concernee, details)
    VALUES (seq_audit.NEXTVAL, USER, v_action, 'PRODUIT',
            'Produit ' || COALESCE(:NEW.id_produit, :OLD.id_produit) || 
            ' - Ancien prix: ' || :OLD.prix_unitaire || 
            ', Nouveau prix: ' || :NEW.prix_unitaire);
END;
/