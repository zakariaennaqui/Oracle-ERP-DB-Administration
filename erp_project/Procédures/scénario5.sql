-- Scénario 5 : Curseur pour rapport des commandes par client

CREATE OR REPLACE PROCEDURE rapport_commandes_client (
    p_id_client NUMBER
) AS
    CURSOR cur_commandes IS
        SELECT c.id_commande, c.date_commande, c.total,
               u.nom as nom_utilisateur, u.prenom as prenom_utilisateur
        FROM COMMANDE c
        JOIN UTILISATEUR u ON c.id_user = u.id_user
        WHERE c.id_client = p_id_client
        ORDER BY c.date_commande DESC;
    
    v_commande cur_commandes%ROWTYPE;
    v_total_client NUMBER := 0;
BEGIN
    OPEN cur_commandes;
    
    DBMS_OUTPUT.PUT_LINE('=== RAPPORT DES COMMANDES ===');
    
    LOOP
        FETCH cur_commandes INTO v_commande;
        EXIT WHEN cur_commandes%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Commande: ' || v_commande.id_commande || 
                            ' - Date: ' || TO_CHAR(v_commande.date_commande, 'DD/MM/YYYY') ||
                            ' - Total: ' || v_commande.total ||
                            ' - Gestionnaire: ' || v_commande.prenom_utilisateur || ' ' || v_commande.nom_utilisateur);
        
        v_total_client := v_total_client + v_commande.total;
    END LOOP;
    
    CLOSE cur_commandes;
    
    DBMS_OUTPUT.PUT_LINE('Total général client: ' || v_total_client);
END;
/