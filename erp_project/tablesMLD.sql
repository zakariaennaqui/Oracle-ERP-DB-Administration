-- 1. UTILISATEUR
CREATE TABLE UTILISATEUR (
    id_user NUMBER PRIMARY KEY,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    mot_de_passe VARCHAR2(100),
    role VARCHAR2(20) CHECK (role IN ('ADMIN', 'GESTIONNAIRE', 'COMPTABLE')),
    statut VARCHAR2(10) DEFAULT 'ACTIF',
    date_creation DATE DEFAULT SYSDATE,
    derniere_connexion DATE
);

-- 2. CLIENT
CREATE TABLE CLIENT (
    id_client NUMBER PRIMARY KEY,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    email VARCHAR2(100),
    telephone VARCHAR2(15),
    adresse VARCHAR2(200),
    ville VARCHAR2(50),
    pays VARCHAR2(50),
    date_inscription DATE DEFAULT SYSDATE,
    statut VARCHAR2(10) DEFAULT 'ACTIF'
);

-- 3. PRODUIT
CREATE TABLE PRODUIT (
    id_produit NUMBER PRIMARY KEY,
    reference VARCHAR2(20) UNIQUE,
    libelle VARCHAR2(100),
    description VARCHAR2(500),
    prix_unitaire NUMBER(10,2),
    quantite_stock NUMBER DEFAULT 0,
    seuil_alerte NUMBER DEFAULT 10,
    categorie VARCHAR2(50),
    statut VARCHAR2(10) DEFAULT 'DISPONIBLE'
);

-- 4. COMMANDE
CREATE TABLE COMMANDE (
    id_commande NUMBER PRIMARY KEY,
    date_commande DATE DEFAULT SYSDATE,
    statut VARCHAR2(20) DEFAULT 'EN_ATTENTE',
    total NUMBER(10,2) DEFAULT 0,
    id_client NUMBER REFERENCES CLIENT(id_client),
    id_user NUMBER REFERENCES UTILISATEUR(id_user)
);

-- 5. LIGNE_COMMANDE
CREATE TABLE LIGNE_COMMANDE (
    id_ligne NUMBER PRIMARY KEY,
    id_commande NUMBER REFERENCES COMMANDE(id_commande),
    id_produit NUMBER REFERENCES PRODUIT(id_produit),
    quantite NUMBER,
    prix_unitaire NUMBER(10,2)
);

-- 6. PAIEMENT
CREATE TABLE PAIEMENT (
    id_paiement NUMBER PRIMARY KEY,
    date_paiement DATE DEFAULT SYSDATE,
    montant NUMBER(10,2),
    mode_paiement VARCHAR2(20),
    statut_paiement VARCHAR2(20) DEFAULT 'EN_ATTENTE',
    reference_transaction VARCHAR2(100),
    id_commande NUMBER REFERENCES COMMANDE(id_commande)
);

-- 7. STOCK_MOUVEMENT
CREATE TABLE STOCK_MOUVEMENT (
    id_mouvement NUMBER PRIMARY KEY,
    type_mouvement VARCHAR2(10) CHECK (type_mouvement IN ('ENTREE', 'SORTIE')),
    quantite NUMBER,
    date_mouvement DATE DEFAULT SYSDATE,
    motif VARCHAR2(200),
    id_produit NUMBER REFERENCES PRODUIT(id_produit)
);

-- 8. AUDIT_LOG
CREATE TABLE AUDIT_LOG (
    id_log NUMBER PRIMARY KEY,
    utilisateur VARCHAR2(100),
    action VARCHAR2(50),
    table_concernee VARCHAR2(50),
    date_action DATE DEFAULT SYSDATE,
    details VARCHAR2(500)
);