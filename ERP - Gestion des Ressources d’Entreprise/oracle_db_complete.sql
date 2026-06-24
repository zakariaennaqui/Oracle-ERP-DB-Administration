-- ============================================
-- PROJET:
-- Administration des Bases de Données
-- ============================================

-- ============================================
-- 1. CRÉATION DES TABLES (DDL)
-- ============================================

-- Table DEPARTEMENT
CREATE TABLE DEPARTEMENT (
    id_departement NUMBER PRIMARY KEY,
    nom_departement VARCHAR2(100) NOT NULL,
    budget_annuel NUMBER(15,2),
    date_creation DATE DEFAULT SYSDATE,
    responsable NUMBER
);

-- Table EMPLOYE
CREATE TABLE EMPLOYE (
    id_employe NUMBER PRIMARY KEY,
    matricule VARCHAR2(20) UNIQUE NOT NULL,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    date_naissance DATE,
    date_embauche DATE DEFAULT SYSDATE,
    salaire_base NUMBER(10,2) NOT NULL,
    statut VARCHAR2(20) CHECK (statut IN ('ACTIF', 'INACTIF', 'CONGE')),
    email VARCHAR2(100),
    telephone VARCHAR2(20),
    poste VARCHAR2(50),
    id_departement NUMBER,
    CONSTRAINT fk_emp_dept FOREIGN KEY (id_departement) 
        REFERENCES DEPARTEMENT(id_departement)
);

-- Table CLIENT
CREATE TABLE CLIENT (
    id_client NUMBER PRIMARY KEY,
    nom VARCHAR2(100) NOT NULL,
    prenom VARCHAR2(100),
    type_client VARCHAR2(20) CHECK (type_client IN ('PARTICULIER', 'ENTREPRISE')),
    email VARCHAR2(100),
    telephone VARCHAR2(20),
    adresse VARCHAR2(200)
);

-- Table FOURNISSEUR
CREATE TABLE FOURNISSEUR (
    id_fournisseur NUMBER PRIMARY KEY,
    nom VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    telephone VARCHAR2(20),
    adresse VARCHAR2(200)
);

-- Table PRODUIT
CREATE TABLE PRODUIT (
    id_produit NUMBER PRIMARY KEY,
    nom_produit VARCHAR2(100) NOT NULL,
    categorie VARCHAR2(50),
    prix_unitaire NUMBER(10,2) NOT NULL,
    seuil_alerte NUMBER DEFAULT 10,
    id_fournisseur NUMBER,
    CONSTRAINT fk_prod_fourn FOREIGN KEY (id_fournisseur) 
        REFERENCES FOURNISSEUR(id_fournisseur)
);

-- Table ENTREPOT
CREATE TABLE ENTREPOT (
    id_entrepot NUMBER PRIMARY KEY,
    nom VARCHAR2(100) NOT NULL,
    localisation VARCHAR2(200),
    responsable_stock NUMBER,
    CONSTRAINT fk_ent_resp FOREIGN KEY (responsable_stock) 
        REFERENCES EMPLOYE(id_employe)
);

-- Table STOCKS (gère les quantités par entrepôt)
CREATE TABLE STOCKS (
    id_mouvement NUMBER PRIMARY KEY,
    id_produit NUMBER NOT NULL,
    id_entrepot NUMBER NOT NULL,
    quantite NUMBER NOT NULL,
    CONSTRAINT fk_stock_prod FOREIGN KEY (id_produit) 
        REFERENCES PRODUIT(id_produit),
    CONSTRAINT fk_stock_ent FOREIGN KEY (id_entrepot) 
        REFERENCES ENTREPOT(id_entrepot)
);

-- Table COMMANDE
CREATE TABLE COMMANDE (
    id_commande NUMBER PRIMARY KEY,
    id_client NUMBER NOT NULL,
    date_commande DATE DEFAULT SYSDATE,
    statut VARCHAR2(20) CHECK (statut IN ('EN_COURS', 'VALIDEE', 'ANNULEE', 'LIVREE')),
    montant_total NUMBER(15,2),
    id_employe NUMBER,
    CONSTRAINT fk_cmd_client FOREIGN KEY (id_client) 
        REFERENCES CLIENT(id_client),
    CONSTRAINT fk_cmd_emp FOREIGN KEY (id_employe) 
        REFERENCES EMPLOYE(id_employe)
);

-- Table LIGNE_COMMANDE
CREATE TABLE LIGNE_COMMANDE (
    id_ligne NUMBER PRIMARY KEY,
    id_commande NUMBER NOT NULL,
    id_produit NUMBER NOT NULL,
    quantite NUMBER NOT NULL,
    prix_unitaire NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_ligne_cmd FOREIGN KEY (id_commande) 
        REFERENCES COMMANDE(id_commande),
    CONSTRAINT fk_ligne_prod FOREIGN KEY (id_produit) 
        REFERENCES PRODUIT(id_produit)
);

-- Table COMPTE_BANCAIRE
CREATE TABLE COMPTE_BANCAIRE (
    numero_compte VARCHAR2(50) PRIMARY KEY,
    banque VARCHAR2(100),
    solde NUMBER(15,2) DEFAULT 0,
    type_compte VARCHAR2(20) CHECK (type_compte IN ('COURANT', 'EPARGNE')),
    date_ouverture DATE DEFAULT SYSDATE
);

-- Table BUDGET
CREATE TABLE BUDGET (
    id_budget NUMBER PRIMARY KEY,
    periode VARCHAR2(20),
    montant_prevu NUMBER(15,2),
    montant_consomme NUMBER(15,2) DEFAULT 0,
    id_departement NUMBER,
    CONSTRAINT fk_budget_dept FOREIGN KEY (id_departement) 
        REFERENCES DEPARTEMENT(id_departement)
);

-- Table TRANSACTION
CREATE TABLE TRANSACTION (
    id_transaction NUMBER PRIMARY KEY,
    date_transaction DATE DEFAULT SYSDATE,
    type_transaction VARCHAR2(20) CHECK (type_transaction IN ('DEBIT', 'CREDIT')),
    montant NUMBER(15,2) NOT NULL,
    description VARCHAR2(200),
    reference_operation VARCHAR2(50),
    id_compte NUMBER,
    id_departement NUMBER,
    CONSTRAINT fk_trans_dept FOREIGN KEY (id_departement) 
        REFERENCES DEPARTEMENT(id_departement),
    CONSTRAINT chk_montant CHECK (montant > 0)
);

-- Tables pour la gestion des primes et salaires
CREATE TABLE PRIMES_PERFORMANCE (
    id_prime NUMBER PRIMARY KEY,
    id_employe NUMBER NOT NULL,
    mois NUMBER CHECK (mois BETWEEN 1 AND 12),
    annee NUMBER,
    montant NUMBER(10,2),
    CONSTRAINT fk_prime_emp FOREIGN KEY (id_employe) 
        REFERENCES EMPLOYE(id_employe)
);

CREATE TABLE PRIMES_ANCIENNETE (
    id_prime NUMBER PRIMARY KEY,
    id_employe NUMBER NOT NULL,
    mois NUMBER CHECK (mois BETWEEN 1 AND 12),
    annee NUMBER,
    montant NUMBER(10,2),
    CONSTRAINT fk_prime_anc_emp FOREIGN KEY (id_employe) 
        REFERENCES EMPLOYE(id_employe)
);

CREATE TABLE PRIMES_DEPARTEMENT (
    id_prime NUMBER PRIMARY KEY,
    id_employe NUMBER NOT NULL,
    mois NUMBER CHECK (mois BETWEEN 1 AND 12),
    annee NUMBER,
    montant NUMBER(10,2),
    CONSTRAINT fk_prime_dept_emp FOREIGN KEY (id_employe) 
        REFERENCES EMPLOYE(id_employe)
);

-- Table pour stocker les salaires calculés
CREATE TABLE SALAIRES_MENSUELS (
    id_salaire NUMBER PRIMARY KEY,
    id_employe NUMBER NOT NULL,
    montant_total NUMBER(10,2) NOT NULL,
    mois NUMBER CHECK (mois BETWEEN 1 AND 12),
    annee NUMBER,
    date_paiement DATE DEFAULT SYSDATE,
    CONSTRAINT fk_sal_emp FOREIGN KEY (id_employe) 
        REFERENCES EMPLOYE(id_employe)
);

-- Table d'audit
CREATE TABLE AUDIT_LOG (
    id_audit NUMBER PRIMARY KEY,
    table_name VARCHAR2(50),
    operation VARCHAR2(10),
    id_employe NUMBER,
    ancienne_valeur NUMBER,
    nouvelle_valeur NUMBER,
    user_name VARCHAR2(50),
    date_operation DATE DEFAULT SYSDATE
);

-- Table pour les alertes de stock
CREATE TABLE ALERTES_STOCK (
    id_alerte NUMBER PRIMARY KEY,
    produit_nom VARCHAR2(100),
    entrepot VARCHAR2(50),
    quantite NUMBER,
    seuil NUMBER,
    date_alerte DATE DEFAULT SYSDATE
);

-- Séquences pour les clés primaires
CREATE SEQUENCE seq_departement START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_employe START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_client START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_fournisseur START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_produit START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_entrepot START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_stock START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_commande START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ligne START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_budget START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_transaction START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_prime START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_salaire START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_audit START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_alerte START WITH 1 INCREMENT BY 1;

-- ============================================
-- 2. INSERTION DE DONNÉES
-- ============================================

-- Départements
INSERT INTO DEPARTEMENT VALUES (seq_departement.NEXTVAL, 'Ventes', 500000, SYSDATE, NULL);
INSERT INTO DEPARTEMENT VALUES (seq_departement.NEXTVAL, 'Logistique', 300000, SYSDATE, NULL);
INSERT INTO DEPARTEMENT VALUES (seq_departement.NEXTVAL, 'Finance', 400000, SYSDATE, NULL);

-- Employés
INSERT INTO EMPLOYE VALUES (seq_employe.NEXTVAL, 'EMP001', 'ALAMI', 'Hassan', 
    TO_DATE('1985-03-15', 'YYYY-MM-DD'), TO_DATE('2020-01-10', 'YYYY-MM-DD'), 
    5000, 'ACTIF', 'h.alami@company.ma', '0612345678', 'Chef des ventes', 1);

INSERT INTO EMPLOYE VALUES (seq_employe.NEXTVAL, 'EMP002', 'BENALI', 'Fatima', 
    TO_DATE('1990-07-22', 'YYYY-MM-DD'), TO_DATE('2021-03-15', 'YYYY-MM-DD'), 
    4500, 'ACTIF', 'f.benali@company.ma', '0623456789', 'Responsable logistique', 2);

INSERT INTO EMPLOYE VALUES (seq_employe.NEXTVAL, 'EMP003', 'IDRISSI', 'Mohammed', 
    TO_DATE('1988-11-30', 'YYYY-MM-DD'), TO_DATE('2019-06-01', 'YYYY-MM-DD'), 
    6000, 'ACTIF', 'm.idrissi@company.ma', '0634567890', 'Directeur financier', 3);

-- Clients
INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'TAZI', 'Amal', 'PARTICULIER', 
    'a.tazi@email.ma', '0645678901', 'Casablanca');

INSERT INTO CLIENT VALUES (seq_client.NEXTVAL, 'TechCorp', NULL, 'ENTREPRISE', 
    'contact@techcorp.ma', '0522123456', 'Rabat');

-- Fournisseurs
INSERT INTO FOURNISSEUR VALUES (seq_fournisseur.NEXTVAL, 'DistribMaroc', 
    'contact@distribmaroc.ma', '0522334455', 'Casablanca');

-- Produits
INSERT INTO PRODUIT VALUES (seq_produit.NEXTVAL, 'Ordinateur Portable', 
    'Informatique', 8000, 5, 1);

INSERT INTO PRODUIT VALUES (seq_produit.NEXTVAL, 'Souris sans fil', 
    'Accessoires', 150, 20, 1);

INSERT INTO PRODUIT VALUES (seq_produit.NEXTVAL, 'Clavier mécanique', 
    'Accessoires', 500, 15, 1);

-- Entrepôts
INSERT INTO ENTREPOT VALUES (seq_entrepot.NEXTVAL, 'Entrepôt Central', 
    'Casablanca', 2);

-- Stocks
INSERT INTO STOCKS VALUES (seq_stock.NEXTVAL, 1, 1, 25);
INSERT INTO STOCKS VALUES (seq_stock.NEXTVAL, 2, 1, 100);
INSERT INTO STOCKS VALUES (seq_stock.NEXTVAL, 3, 1, 8);

-- Primes
INSERT INTO PRIMES_PERFORMANCE VALUES (seq_prime.NEXTVAL, 1, 12, 2024, 800);
INSERT INTO PRIMES_ANCIENNETE VALUES (seq_prime.NEXTVAL, 1, 12, 2024, 500);
INSERT INTO PRIMES_DEPARTEMENT VALUES (seq_prime.NEXTVAL, 1, 12, 2024, 300);

COMMIT;

-- ============================================
-- 3. PROCÉDURES STOCKÉES
-- ============================================

-- Procédure: Calculer le salaire mensuel d'un employé
CREATE OR REPLACE PROCEDURE calculer_salaire_mensuel(
    p_mois NUMBER,
    p_annee NUMBER
) IS
    v_sql VARCHAR2(4000);
    v_employe_id NUMBER;
    v_salaire_base NUMBER;
    v_primes NUMBER;
    v_salaire_total NUMBER;
    
    CURSOR c_employes IS
        SELECT id_employe, salaire_base 
        FROM EMPLOYE 
        WHERE statut = 'ACTIF';
BEGIN
    FOR emp IN c_employes LOOP
        v_sql := 'SELECT SUM(montant) FROM (' ||
                 'SELECT montant FROM PRIMES_PERFORMANCE WHERE id_employe = :1 ' ||
                 'UNION ALL ' ||
                 'SELECT montant FROM PRIMES_ANCIENNETE WHERE id_employe = :1 ' ||
                 'UNION ALL ' ||
                 'SELECT montant FROM PRIMES_DEPARTEMENT WHERE id_employe = :1 ' ||
                 ') AND mois = :2 AND annee = :3';
        
        EXECUTE IMMEDIATE v_sql INTO v_primes 
            USING emp.id_employe, p_mois, p_annee;
        
        v_salaire_total := emp.salaire_base + NVL(v_primes, 0);
        
        INSERT INTO SALAIRES_MENSUELS 
        VALUES (seq_salaire.NEXTVAL, emp.id_employe, v_salaire_total, 
                p_mois, p_annee, SYSDATE);
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salaires calculés pour ' || p_mois || '/' || p_annee);
END;
/

-- Procédure: Vérifier les stocks et générer des alertes
CREATE OR REPLACE PROCEDURE verifier_stocks_dynamique(
    p_categorie_produit VARCHAR2 DEFAULT NULL
) IS
    TYPE t_alerte IS RECORD (
        produit_nom VARCHAR2(100),
        entrepot VARCHAR2(50),
        quantite NUMBER,
        seuil NUMBER
    );
    
    TYPE t_alertes_tab IS TABLE OF t_alerte;
    v_alertes t_alertes_tab;
    v_sql VARCHAR2(4000);
BEGIN
    v_sql := 'SELECT p.nom_produit, e.nom_entrepot, s.quantite, p.seuil_alerte ' ||
             'FROM STOCKS s ' ||
             'JOIN PRODUIT p ON s.id_produit = p.id_produit ' ||
             'JOIN ENTREPOT e ON s.id_entrepot = e.id_entrepot ' ||
             'WHERE s.quantite <= p.seuil_alerte';
    
    IF p_categorie_produit IS NOT NULL THEN
        v_sql := v_sql || ' AND p.categorie = :cat';
        EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_alertes 
            USING p_categorie_produit;
    ELSE
        EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_alertes;
    END IF;
    
    FOR i IN 1..v_alertes.COUNT LOOP
        INSERT INTO ALERTES_STOCK 
        VALUES (seq_alerte.NEXTVAL, v_alertes(i).produit_nom, 
                v_alertes(i).entrepot, v_alertes(i).quantite, 
                v_alertes(i).seuil, SYSDATE);
        
        DBMS_OUTPUT.PUT_LINE('ALERTE: ' || v_alertes(i).produit_nom || 
                           ' - Stock: ' || v_alertes(i).quantite || 
                           ' / Seuil: ' || v_alertes(i).seuil);
    END LOOP;
    
    COMMIT;
END;
/

-- ============================================
-- 4. FONCTIONS
-- ============================================

-- Fonction: Calculer le total d'une commande
CREATE OR REPLACE FUNCTION calculer_total_commande(
    p_id_commande NUMBER
) RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT SUM(quantite * prix_unitaire)
    INTO v_total
    FROM LIGNE_COMMANDE
    WHERE id_commande = p_id_commande;
    
    RETURN NVL(v_total, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Fonction: Vérifier la disponibilité du stock
CREATE OR REPLACE FUNCTION verifier_disponibilite_stock(
    p_id_produit NUMBER,
    p_quantite_demandee NUMBER
) RETURN BOOLEAN IS
    v_quantite_totale NUMBER := 0;
BEGIN
    SELECT SUM(quantite)
    INTO v_quantite_totale
    FROM STOCKS
    WHERE id_produit = p_id_produit;
    
    RETURN v_quantite_totale >= p_quantite_demandee;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;
/

-- ============================================
-- 5. PACKAGE DE GESTION DES COMMANDES
-- ============================================

CREATE OR REPLACE PACKAGE pkg_gestion_commandes IS
    PROCEDURE creer_commande(
        p_id_client NUMBER,
        p_liste_produits VARCHAR2,
        p_id_commande OUT NUMBER
    );
    
    FUNCTION calculer_total_commande(
        p_id_commande NUMBER
    ) RETURN NUMBER;
    
    PROCEDURE valider_stock_disponible(
        p_id_commande NUMBER,
        p_disponible OUT BOOLEAN
    );
    
    PROCEDURE generer_facture(
        p_id_commande NUMBER
    );
END pkg_gestion_commandes;
/

CREATE OR REPLACE PACKAGE BODY pkg_gestion_commandes IS
    
    PROCEDURE creer_commande(
        p_id_client NUMBER,
        p_liste_produits VARCHAR2,
        p_id_commande OUT NUMBER
    ) IS
        v_sql VARCHAR2(4000);
        v_produit_id NUMBER;
        v_quantite NUMBER;
        v_pos_debut NUMBER := 1;
        v_pos_sep NUMBER;
        v_item VARCHAR2(100);
    BEGIN
        INSERT INTO COMMANDE (id_commande, id_client, date_commande, statut)
        VALUES (seq_commande.NEXTVAL, p_id_client, SYSDATE, 'EN_COURS')
        RETURNING id_commande INTO p_id_commande;
        
        LOOP
            v_pos_sep := INSTR(p_liste_produits, ',', v_pos_debut);
            
            IF v_pos_sep = 0 THEN
                v_item := SUBSTR(p_liste_produits, v_pos_debut);
            ELSE
                v_item := SUBSTR(p_liste_produits, v_pos_debut, 
                                v_pos_sep - v_pos_debut);
            END IF;
            
            v_produit_id := TO_NUMBER(SUBSTR(v_item, 1, INSTR(v_item, ':') - 1));
            v_quantite := TO_NUMBER(SUBSTR(v_item, INSTR(v_item, ':') + 1));
            
            INSERT INTO LIGNE_COMMANDE (id_ligne, id_commande, id_produit, 
                                       quantite, prix_unitaire)
            SELECT seq_ligne.NEXTVAL, p_id_commande, id_produit, 
                   v_quantite, prix_unitaire
            FROM PRODUIT
            WHERE id_produit = v_produit_id;
            
            EXIT WHEN v_pos_sep = 0;
            v_pos_debut := v_pos_sep + 1;
        END LOOP;
        
        UPDATE COMMANDE
        SET montant_total = calculer_total_commande(p_id_commande)
        WHERE id_commande = p_id_commande;
        
        COMMIT;
    END creer_commande;
    
    FUNCTION calculer_total_commande(
        p_id_commande NUMBER
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT SUM(quantite * prix_unitaire)
        INTO v_total
        FROM LIGNE_COMMANDE
        WHERE id_commande = p_id_commande;
        
        RETURN NVL(v_total, 0);
    END calculer_total_commande;
    
    PROCEDURE valider_stock_disponible(
        p_id_commande NUMBER,
        p_disponible OUT BOOLEAN
    ) IS
        v_count NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM LIGNE_COMMANDE lc
        WHERE lc.id_commande = p_id_commande
        AND NOT EXISTS (
            SELECT 1
            FROM STOCKS s
            WHERE s.id_produit = lc.id_produit
            HAVING SUM(s.quantite) >= lc.quantite
            GROUP BY s.id_produit
        );
        
        p_disponible := (v_count = 0);
    END valider_stock_disponible;
    
    PROCEDURE generer_facture(
        p_id_commande NUMBER
    ) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('===== FACTURE =====');
        DBMS_OUTPUT.PUT_LINE('Commande N°: ' || p_id_commande);
        DBMS_OUTPUT.PUT_LINE('Total: ' || 
            calculer_total_commande(p_id_commande) || ' MAD');
    END generer_facture;
    
END pkg_gestion_commandes;
/

-- ============================================
-- 6. TRIGGERS
-- ============================================

-- Trigger: Audit des modifications de salaires
CREATE OR REPLACE TRIGGER audit_modifications_sensibles
AFTER INSERT OR UPDATE OR DELETE ON SALAIRES_MENSUELS
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_table_name VARCHAR2(50) := 'SALAIRES_MENSUELS';
    v_user VARCHAR2(50) := USER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        INSERT INTO AUDIT_LOG
        VALUES (seq_audit.NEXTVAL, v_table_name, v_operation,
                :NEW.id_employe, NULL, :NEW.montant_total, v_user, SYSDATE);
    
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        INSERT INTO AUDIT_LOG
        VALUES (seq_audit.NEXTVAL, v_table_name, v_operation,
                :NEW.id_employe, :OLD.montant_total, :NEW.montant_total, 
                v_user, SYSDATE);
    
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        INSERT INTO AUDIT_LOG
        VALUES (seq_audit.NEXTVAL, v_table_name, v_operation,
                :OLD.id_employe, :OLD.montant_total, NULL, v_user, SYSDATE);
    END IF;
END;
/

-- Trigger: Mise à jour automatique du montant total de commande
CREATE OR REPLACE TRIGGER maj_montant_commande
AFTER INSERT OR UPDATE OR DELETE ON LIGNE_COMMANDE
FOR EACH ROW
DECLARE
    v_id_commande NUMBER;
    v_total NUMBER;
BEGIN
    IF DELETING THEN
        v_id_commande := :OLD.id_commande;
    ELSE
        v_id_commande := :NEW.id_commande;
    END IF;
    
    SELECT SUM(quantite * prix_unitaire)
    INTO v_total
    FROM LIGNE_COMMANDE
    WHERE id_commande = v_id_commande;
    
    UPDATE COMMANDE
    SET montant_total = NVL(v_total, 0)
    WHERE id_commande = v_id_commande;
END;
/

-- Trigger: Vérification du stock avant validation de commande
CREATE OR REPLACE TRIGGER verif_stock_avant_validation
BEFORE UPDATE OF statut ON COMMANDE
FOR EACH ROW
WHEN (NEW.statut = 'VALIDEE')
DECLARE
    v_stock_insuffisant EXCEPTION;
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM LIGNE_COMMANDE lc
    WHERE lc.id_commande = :NEW.id_commande
    AND NOT EXISTS (
        SELECT 1
        FROM STOCKS s
        WHERE s.id_produit = lc.id_produit
        HAVING SUM(s.quantite) >= lc.quantite
        GROUP BY s.id_produit
    );
    
    IF v_count > 0 THEN
        RAISE v_stock_insuffisant;
    END IF;
EXCEPTION
    WHEN v_stock_insuffisant THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Stock insuffisant pour valider cette commande');
END;
/

-- ============================================
-- 7. Test
-- ============================================

-- Test de calcul de salaire
BEGIN
    calculer_salaire_mensuel(12, 2024);
END;
/

-- Test de vérification de stocks
BEGIN
    verifier_stocks_dynamique('Accessoires');
END;
/

-- Test de création de commande
DECLARE
    v_id_cmd NUMBER;
    v_disponible BOOLEAN;
BEGIN
    pkg_gestion_commandes.creer_commande(
        p_id_client => 1,
        p_liste_produits => '1:2,2:5',
        p_id_commande => v_id_cmd
    );
    
    DBMS_OUTPUT.PUT_LINE('Commande créée: ' || v_id_cmd);
    
    pkg_gestion_commandes.valider_stock_disponible(v_id_cmd, v_disponible);
    
    IF v_disponible THEN
        DBMS_OUTPUT.PUT_LINE('Stock disponible');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Stock insuffisant');
    END IF;
END;
/










-- ============================================
-- CRÉATION D'INDEX D'OPTIMISATION
-- ============================================

-- Index sur les clés étrangères (améliore les jointures)
CREATE INDEX idx_emp_dept ON EMPLOYE(id_departement);
CREATE INDEX idx_prod_fourn ON PRODUIT(id_fournisseur);
CREATE INDEX idx_stock_prod ON STOCKS(id_produit);
CREATE INDEX idx_stock_ent ON STOCKS(id_entrepot);
CREATE INDEX idx_cmd_client ON COMMANDE(id_client);
CREATE INDEX idx_cmd_emp ON COMMANDE(id_employe);
CREATE INDEX idx_ligne_cmd ON LIGNE_COMMANDE(id_commande);
CREATE INDEX idx_ligne_prod ON LIGNE_COMMANDE(id_produit);
CREATE INDEX idx_trans_dept ON TRANSACTION(id_departement);

-- Index composites pour les requêtes fréquentes
CREATE INDEX idx_cmd_date_statut ON COMMANDE(date_commande, statut);
CREATE INDEX idx_emp_statut_dept ON EMPLOYE(statut, id_departement);

-- Index sur les colonnes de recherche fréquentes
CREATE INDEX idx_client_nom ON CLIENT(nom);
CREATE INDEX idx_prod_nom ON PRODUIT(nom_produit);
CREATE INDEX idx_emp_matricule ON EMPLOYE(matricule);

-- Index basés sur fonction
CREATE INDEX idx_client_nom_upper ON CLIENT(UPPER(nom));