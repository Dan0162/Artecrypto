## Proyecto: ArteCrypto — Scripts SQL
```markdown
## Project: ArteCrypto — SQL Scripts

English README for the set of SQL scripts included in this repository. The scripts create objects (functions, stored procedures, triggers), sample data loads and usage examples for the "ArteCrypto" system (auctions / NFTs).

## Purpose

This project groups the SQL scripts required to deploy and test the auction and NFT review logic called ArteCrypto. It contains:
- Definitions of functions and stored procedures.
- Triggers for assignment, reassignment and automatic auction creation.
- Seed data and usage examples.

## File structure

Main files included in the root folder:

- `1) Caso_ArteCrypto V4.sql` — Main case script (table creation and primary flow).
- `2) Funciones_ArteCrypto.sql` — Project-defined functions.
- `3) SP_ArteCrypto.sql` — Main stored procedures.
- `4) Trigger_NFT_Asignacion_Revision.sql` — Trigger for assigning NFT reviews.
- `5) Trigger_Reasignacion_Revision.sql` — Trigger for review reassignments.
- `6) Trigger_Revision_AutoSubasta.sql` — Trigger that starts an automatic auction after approval.
- `7) Datos_Subastas V4.sql` — Example data for auctions.
- `8) Ejemplos_Uso.sql` — Queries and examples to test functionality.
- `Datos_de_Prueba_NFT's.sql` — Additional NFT test data.
- `PujayAprobacionRechazo.sql` — Example scripts for bids and approvals/rejections.

## Requirements

- Microsoft SQL Server (any edition compatible with the features used).
- A user with permissions to create databases and objects (e.g. `sa` or a user with `db_owner` role).
- SQL Server Management Studio (SSMS) or the `sqlcmd` utility to run the scripts from PowerShell/terminal.

##Table relationships diagram
<img width="1894" height="1679" alt="Untitled" src="https://github.com/user-attachments/assets/011fec19-8825-427b-b644-19763cfd62f8" />
