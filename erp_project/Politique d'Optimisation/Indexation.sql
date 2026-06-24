-- Index sur les clés étrangères
CREATE INDEX idx_commande_client ON COMMANDE(id_client);
CREATE INDEX idx_commande_user ON COMMANDE(id_user);
CREATE INDEX idx_ligne_commande ON LIGNE_COMMANDE(id_commande);
CREATE INDEX idx_ligne_produit ON LIGNE_COMMANDE(id_produit);
CREATE INDEX idx_stock_produit ON STOCK_MOUVEMENT(id_produit);

-- Index pour les recherches fréquentes
CREATE INDEX idx_client_email ON CLIENT(email);
CREATE INDEX idx_produit_reference ON PRODUIT(reference);
CREATE INDEX idx_audit_date ON AUDIT_LOG(date_action);