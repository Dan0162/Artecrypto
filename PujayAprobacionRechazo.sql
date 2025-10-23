-- Approval/Reject and ModifyAuction examples
-- usp_AprobarNFT 1,'Okay'

-- usp_RechazarNFT 3, 'Because I don't want to'

-- usp_ModificarSubasta 2,5.00,-24

-- Queries to check tables
-- Select * from Subasta

-- Select * from Correo_log

-- Select * from Puja pu INNER JOIN Estado_Puja ep on ep.ID_EstadoPuja = pu.Estado

-- ==========================================================
-- SP FOR BIDDING IN AUCTIONS
-- ==========================================================
-- Bid 1: User 3 bids $10.00
EXEC usp_PujarEnSubasta 
    @ID_Subasta = 1,
    @ID_Persona = 3,
    @Monto = 10.00;
-- Bid 2: User 6 bids $15.00 (beats previous)
EXEC usp_PujarEnSubasta 
    @ID_Subasta = 1     ,
    @ID_Persona = 6,
    @Monto = 15.00;


    -- Bid 4: User 9 bids $20.00 (TIE with user 8)
EXEC usp_PujarEnSubasta 
    @ID_Subasta = 1,
    @ID_Persona = 3,
    @Monto = 20.00;
-- Bid 5: User 10 bids $25.00 (breaks the tie and becomes winning)
EXEC usp_PujarEnSubasta 
    @ID_Subasta = 1,
    @ID_Persona = 10,
    @Monto = 25.00;


-- Select * from Puja pu INNER JOIN Estado_Puja ep on ep.ID_EstadoPuja = pu.Estado

-- Select * from Billetera

-- Update wallet balances
Update Billetera
SET Saldo_Disponible = 40
WHERE ID_Persona = 3 or ID_Persona = 10