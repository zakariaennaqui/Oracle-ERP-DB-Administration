-- Création des rôles
CREATE ROLE role_admin;
CREATE ROLE role_gestionnaire;
CREATE ROLE role_comptable;

-- Attribution des privilèges
GRANT CREATE SESSION TO role_admin, role_gestionnaire, role_comptable;

-- ADMIN : Tous les privilèges
GRANT ALL PRIVILEGES ON UTILISATEUR TO role_admin;
GRANT ALL PRIVILEGES ON CLIENT TO role_admin;
GRANT ALL PRIVILEGES ON PRODUIT TO role_admin;
GRANT ALL PRIVILEGES ON COMMANDE TO role_admin;
GRANT ALL PRIVILEGES ON LIGNE_COMMANDE TO role_admin;
GRANT ALL PRIVILEGES ON PAIEMENT TO role_admin;
GRANT ALL PRIVILEGES ON STOCK_MOUVEMENT TO role_admin;
GRANT ALL PRIVILEGES ON AUDIT_LOG TO role_admin;

-- GESTIONNAIRE : CRUD sur clients, produits, commandes
GRANT SELECT, INSERT, UPDATE ON CLIENT TO role_gestionnaire;
GRANT SELECT, INSERT, UPDATE ON PRODUIT TO role_gestionnaire;
GRANT SELECT, INSERT, UPDATE ON COMMANDE TO role_gestionnaire;
GRANT SELECT, INSERT, UPDATE ON LIGNE_COMMANDE TO role_gestionnaire;
GRANT SELECT, INSERT, UPDATE ON STOCK_MOUVEMENT TO role_gestionnaire;

-- COMPTABLE : Lecture commandes + gestion paiements
GRANT SELECT ON COMMANDE TO role_comptable;
GRANT SELECT ON CLIENT TO role_comptable;
GRANT SELECT, INSERT, UPDATE ON PAIEMENT TO role_comptable;

-- Création d'utilisateurs
CREATE USER admin_erp IDENTIFIED BY "Admin123!";
CREATE USER gest_erp IDENTIFIED BY "Gest123!";
CREATE USER comptable_erp IDENTIFIED BY "Compta123!";

-- Attribution des rôles
GRANT role_admin TO admin_erp;
GRANT role_gestionnaire TO gest_erp;
GRANT role_comptable TO comptable_erp;