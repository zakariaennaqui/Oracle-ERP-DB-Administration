
-- 1. Insérer un utilisateur
INSERT INTO UTILISATEUR (id_user, nom, email, role) 
VALUES (1, 'Admin System', 'admin@erp.com', 'ADMIN');

-- 2. Insérer un client
INSERT INTO CLIENT (id_client, nom, email) 
VALUES (1, 'Client Test', 'client@test.com');

-- 3. Insérer des produits
INSERT INTO PRODUIT (id_produit, libelle, prix_unitaire, quantite_stock) 
VALUES (1, 'Ordinateur Portable', 800, 20);

INSERT INTO PRODUIT (id_produit, libelle, prix_unitaire, quantite_stock) 
VALUES (2, 'Souris Sans Fil', 25, 50);

-- Valider
COMMIT;





-- l'affichage des sorties
SET SERVEROUTPUT ON;

-- Tester la procédure passer_commande
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





-- Voir la commande créée
SELECT * FROM COMMANDE;

-- Voir les lignes de commande
SELECT * FROM LIGNE_COMMANDE;

-- Vérifier le stock mis à jour
SELECT id_produit, libelle, quantite_stock FROM PRODUIT;

-- Voir les logs d'audit
SELECT * FROM AUDIT_LOG ORDER BY date_action DESC;








-- rôles
CONNECT gest_erp/Gest123!@localhost:1521/XE
-- créer des commande

CONNECT comptable_erp/Compta123!@localhost:1521/XE
-- voir les paiements