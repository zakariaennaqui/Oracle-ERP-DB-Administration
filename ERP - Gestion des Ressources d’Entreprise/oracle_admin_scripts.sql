-- ============================================
-- SCRIPTS D'ADMINISTRATION BASE DE DONNÉES
-- Gestion des utilisateurs, privilèges et rôles
-- ============================================

-- ============================================
-- 1. CRÉATION DES UTILISATEURS
-- ============================================

-- Utilisateur DBA (Administrateur de la base)
CREATE USER admin_db IDENTIFIED BY Admin123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- Utilisateur pour l'application (accès complet aux tables)
CREATE USER app_user IDENTIFIED BY App123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 100M ON USERS;

-- Utilisateur en lecture seule (pour les rapports)
CREATE USER lecteur_rapports IDENTIFIED BY Lecteur123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON USERS;

-- Utilisateur gestionnaire de commandes
CREATE USER gestionnaire_cmd IDENTIFIED BY Gest123
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 50M ON USERS;

-- ============================================
-- 2. CRÉATION DES RÔLES
-- ============================================

-- Rôle pour la gestion complète
CREATE ROLE role_admin;

-- Rôle pour la gestion des ventes
CREATE ROLE role_ventes;

-- Rôle pour la consultation
CREATE ROLE role_consultation;

-- Rôle pour la gestion des stocks
CREATE ROLE role_logistique;

-- ============================================
-- 3. ATTRIBUTION DES PRIVILÈGES AUX RÔLES
-- ============================================

-- Privilèges pour le rôle administrateur
GRANT CREATE SESSION TO role_admin;
GRANT CREATE TABLE TO role_admin;
GRANT CREATE VIEW TO role_admin;
GRANT CREATE SEQUENCE TO role_admin;
GRANT CREATE PROCEDURE TO role_admin;
GRANT CREATE TRIGGER TO role_admin;

-- Privilèges complets sur toutes les tables
GRANT SELECT, INSERT, UPDATE, DELETE ON DEPARTEMENT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON EMPLOYE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON FOURNISSEUR TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUIT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ENTREPOT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON STOCKS TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON COMMANDE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON LIGNE_COMMANDE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON TRANSACTION TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON BUDGET TO role_admin;

-- Privilèges pour le rôle ventes
GRANT CREATE SESSION TO role_ventes;
GRANT SELECT, INSERT, UPDATE ON CLIENT TO role_ventes;
GRANT SELECT, INSERT, UPDATE ON COMMANDE TO role_ventes;
GRANT SELECT, INSERT, UPDATE ON LIGNE_COMMANDE TO role_ventes;
GRANT SELECT ON PRODUIT TO role_ventes;
GRANT SELECT ON STOCKS TO role_ventes;
GRANT EXECUTE ON pkg_gestion_commandes TO role_ventes;

-- Privilèges pour le rôle consultation
GRANT CREATE SESSION TO role_consultation;
GRANT SELECT ON DEPARTEMENT TO role_consultation;
GRANT SELECT ON EMPLOYE TO role_consultation;
GRANT SELECT ON CLIENT TO role_consultation;
GRANT SELECT ON PRODUIT TO role_consultation;
GRANT SELECT ON COMMANDE TO role_consultation;
GRANT SELECT ON LIGNE_COMMANDE TO role_consultation;
GRANT SELECT ON STOCKS TO role_consultation;
GRANT SELECT ON SALAIRES_MENSUELS TO role_consultation;

-- Privilèges pour le rôle logistique
GRANT CREATE SESSION TO role_logistique;
GRANT SELECT, INSERT, UPDATE ON STOCKS TO role_logistique;
GRANT SELECT, INSERT, UPDATE ON ENTREPOT TO role_logistique;
GRANT SELECT ON PRODUIT TO role_logistique;
GRANT SELECT ON FOURNISSEUR TO role_logistique;
GRANT SELECT ON ALERTES_STOCK TO role_logistique;
GRANT EXECUTE ON verifier_stocks_dynamique TO role_logistique;

-- ============================================
-- 4. ATTRIBUTION DES RÔLES AUX UTILISATEURS
-- ============================================

-- Attribution au DBA
GRANT role_admin TO admin_db;
GRANT DBA TO admin_db;

-- Attribution à l'utilisateur application
GRANT role_admin TO app_user;

-- Attribution au lecteur de rapports
GRANT role_consultation TO lecteur_rapports;

-- Attribution au gestionnaire de commandes
GRANT role_ventes TO gestionnaire_cmd;

-- ============================================
-- 5. VUES
-- ============================================

-- Vue pour masquer les informations sensibles des employés
CREATE OR REPLACE VIEW V_EMPLOYE_PUBLIC AS
SELECT id_employe, matricule, nom, prenom, 
       poste, id_departement, statut
FROM EMPLOYE;

GRANT SELECT ON V_EMPLOYE_PUBLIC TO role_consultation;

-- Vue pour les statistiques de ventes
CREATE OR REPLACE VIEW V_STATS_VENTES AS
SELECT 
    c.id_commande,
    c.date_commande,
    cl.nom || ' ' || cl.prenom AS client,
    c.montant_total,
    c.statut
FROM COMMANDE c
JOIN CLIENT cl ON c.id_client = cl.id_client;

GRANT SELECT ON V_STATS_VENTES TO role_consultation;

-- Vue pour l'état des stocks
CREATE OR REPLACE VIEW V_ETAT_STOCKS AS
SELECT 
    p.nom_produit,
    p.categorie,
    e.nom AS entrepot,
    s.quantite,
    p.seuil_alerte,
    CASE 
        WHEN s.quantite <= p.seuil_alerte THEN 'CRITIQUE'
        WHEN s.quantite <= p.seuil_alerte * 1.5 THEN 'FAIBLE'
        ELSE 'NORMAL'
    END AS etat_stock
FROM STOCKS s
JOIN PRODUIT p ON s.id_produit = p.id_produit
JOIN ENTREPOT e ON s.id_entrepot = e.id_entrepot;

GRANT SELECT ON V_ETAT_STOCKS TO role_logistique;
GRANT SELECT ON V_ETAT_STOCKS TO role_consultation;