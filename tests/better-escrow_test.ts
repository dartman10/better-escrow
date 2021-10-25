
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Testing better-escrow / Just Another Escrow App",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        /* Assign wallets to be used for simulating the escrow participants - seller, buyer, mediator. */
        let seller    = accounts.get('wallet_9')!;
        let buyer     = accounts.get('wallet_8')!;
        let mediator  = accounts.get('wallet_7')!;

        /* Set the sell price. */
        let price     = 'u10000';

        /*
        ------------------------------------------------------------ 
           Test the basic functions.
        ------------------------------------------------------------- 
        */
        let block = chain.mineBlock([
           Tx.contractCall('better-escrow', 'about', [], seller.address),
           Tx.contractCall('better-escrow', 'status-of-contract', [], seller.address),
        ]);
        assertEquals(block.receipts.length, 2);
        assertEquals(block.receipts[0].result.expectOk(), '"Just Another Escrow Application"');
        assertEquals(block.receipts[1].result.expectOk(), '[u0, u0, u0]');

        /*
        ------------------------------------------------------------ 
           Simulate a smooth escrow transaction.                      
        ------------------------------------------------------------- 
        */
        block = chain.mineBlock([

            Tx.contractCall('better-escrow', 'get-principal-contract', [], seller.address),  

            Tx.contractCall('better-escrow', 'bill-create',  [price], seller.address),
            Tx.contractCall('better-escrow', 'bill-accept',  [], buyer.address),

            Tx.contractCall('better-escrow', 'get-balance-seller', [], seller.address),     /* Get initial asset. */
            Tx.contractCall('better-escrow', 'get-balance-buyer',  [], buyer.address),      /* Get initial asset. */          
            Tx.contractCall('better-escrow', 'get-balance-contract',  [], buyer.address),   /* Get initial asset. */          
            
            Tx.contractCall('better-escrow', 'fund-seller',  [], seller.address),
            Tx.contractCall('better-escrow', 'fund-buyer',   [], buyer.address),            

            Tx.contractCall('better-escrow', 'get-balance-seller',   [], seller.address),   /* Get updated asset. */
            Tx.contractCall('better-escrow', 'get-balance-buyer',    [], buyer.address),    /* Get updated asset. */          
            Tx.contractCall('better-escrow', 'get-balance-contract', [], seller.address),   /* Get updated asset. */

            Tx.contractCall('better-escrow', 'fund-release', [], buyer.address),  /* Complete escrow transaction. Give seller back his collateral plus the sell price.  Give buyer back his collateral minus the buy price. */
            
            Tx.contractCall('better-escrow', 'get-balance-seller', [], seller.address),    /* Get updated asset. */
            Tx.contractCall('better-escrow', 'get-balance-buyer',  [], buyer.address),     /* Get updated asset. */          
            Tx.contractCall('better-escrow', 'get-balance-contract', [], seller.address),  /* Get updated asset. */

         ]);

         console.log(' ');
         console.log('-------------------------------------------');
         console.log('-- Simulate a smooth escrow transaction. --');          
         console.log('-------------------------------------------');            
         console.log('seller.address = ' + seller.address);
         console.log('buyer.address  = ' + buyer.address);
         console.log('price          = ' + price);

         console.log('result count   = ' + block.receipts.length);
         /* assertEquals(block.receipts.length, 5); */

         console.log('contract addr  = ' + block.receipts[0].result);

         console.log('bill created   = ' + block.receipts[1].result);
         console.log('bill accepted  = ' + block.receipts[2].result);

         console.log('Seller asset   = ' + block.receipts[3].result);
         console.log('Buyer asset    = ' + block.receipts[4].result);
         console.log('Contract asset = ' + block.receipts[5].result);

         console.log('Seller funded  = ' + block.receipts[6].result);
         console.log('Buyer funded   = ' + block.receipts[7].result);

         console.log('Seller asset   = ' + block.receipts[8].result);
         console.log('Buyer asset    = ' + block.receipts[9].result);
         console.log('Contract asset = ' + block.receipts[10].result);
         
         console.log('Fund release   = ' + block.receipts[11].result);

         console.log('Seller asset   = ' + block.receipts[12].result);
         console.log('Buyer asset    = ' + block.receipts[13].result);
         console.log('Contract asset = ' + block.receipts[14].result);

         assertEquals(block.receipts[1].result.expectOk().expectOk(),  '[u1, u0, u0]');  /* bill-create   */
         assertEquals(block.receipts[2].result.expectOk().expectOk(),  '[u1, u1, u0]');  /* bill-accept   */
         assertEquals(block.receipts[6].result.expectOk().expectOk(),  '[u2, u1, u0]');  /* fund-seller   */
         assertEquals(block.receipts[7].result.expectOk().expectOk(),  '[u2, u2, u0]');  /* fund-buyer    */
         assertEquals(block.receipts[11].result.expectOk().expectOk(), '[u2, u3, u0]');  /* fund-release  */

         

         console.log(' ');  /* blank line */

         /* Compare seller balance. Expect initial balance subtracted with sell price. */
         let asset_expected_seller   = (100000000000000 - (parseInt((price.replace('u','0')),10)));   /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         let asset_transacted_seller = (parseInt((block.receipts[8].result.expectOk()).replace('u','0')));
         assertEquals(asset_transacted_seller, asset_expected_seller); 

         /* console.log(block.receipts[3].result.expectOk().expectOk()); */
         /* assertEquals(block.receipts[3].result.expectOk().expectOk(), '[u2, u2, u0]'); */
         /*
         console.log(block.receipts[4].result.expectOk().expectOk());
         assertEquals(block.receipts[4].result.expectOk().expectOk(), '[u2, u3, u0]');
         */

         console.log(' ');
         console.log('---------------------------------------------');
         console.log('-- Simulate a transaction with a Mediator. --');          
         console.log('---------------------------------------------');            
         

         /*
         export interface Account {
            address: string;
            balance: number;
            name: string;
            mnemonic: string;
            derivation: string;
          }
          */
    },
});
