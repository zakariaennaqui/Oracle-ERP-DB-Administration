-- Scénario 3 : Fonction de calcul du total d'une commande

CREATE OR REPLACE FUNCTION calcul_total_commande (
    p_id_commande NUMBER
) RETURN NUMBER
AS
    v_total NUMBER;
BEGIN
    SELECT SUM(quantite * prix_unitaire)
    INTO v_total
    FROM LIGNE_COMMANDE
    WHERE id_commande = p_id_commande;
    
    RETURN NVL(v_total, 0);
END;
/