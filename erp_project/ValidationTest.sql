-- Test de la procédure passer_commande
DECLARE
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 1 as id_produit, 2 as quantite FROM DUAL
        UNION ALL
        SELECT 2 as id_produit, 1 as quantite FROM DUAL;
    
    passer_commande(1, 1, v_cursor);
    CLOSE v_cursor;
END;
/

-- Test de la fonction calcul_total_commande
SELECT calcul_total_commande(1) FROM DUAL;

-- Test du trigger d'audit
UPDATE PRODUIT SET prix_unitaire = 150 WHERE id_produit = 1;
SELECT * FROM AUDIT_LOG WHERE table_concernee = 'PRODUIT';