
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
        console.log(' ');
        console.log('----------------------------');
        console.log('-- Test basic functions.  --');          
        console.log('----------------------------');            
        console.log(' ');

        let block = chain.mineBlock([
           Tx.contractCall('better-escrow', 'about', [], seller.address),
           Tx.contractCall('better-escrow', 'status-of-contract', [], seller.address),
        ]);

        console.log('about              = ' + block.receipts[0].result);
        console.log('status-of-contract = ' + block.receipts[1].result);

        assertEquals(block.receipts.length, 2);
        assertEquals(block.receipts[0].result.expectOk(), '"Just Another Escrow Application"');
        assertEquals(block.receipts[1].result.expectOk(), 'u6000');

        /*
        ------------------------------------------------------------ 
           Simulate a smooth escrow transaction.                      
        ------------------------------------------------------------- 
        */

        console.log(' ');
        console.log('-------------------------------------------');
        console.log('-- Simulate a smooth escrow transaction. --');          
        console.log('-------------------------------------------');            
        console.log(' ');

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

         console.log('seller.address = ' + seller.address);
         console.log('buyer.address  = ' + buyer.address);
         console.log('price          = ' + price);

         console.log('result count   = ' + block.receipts.length);
         assertEquals(block.receipts.length, 15);  /* expected contract call results */

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

         assertEquals(block.receipts[1].result.expectOk().expectOk(),  'u6100');  /* bill-create   */
         assertEquals(block.receipts[2].result.expectOk().expectOk(),  'u6110');  /* bill-accept   */
         assertEquals(block.receipts[6].result.expectOk().expectOk(),  'u6210');  /* fund-seller   */
         assertEquals(block.receipts[7].result.expectOk().expectOk(),  'u6220');  /* fund-buyer    */
         assertEquals(block.receipts[11].result.expectOk().expectOk(), 'u6230');  /* fund-release  */
       
         console.log(' ');  /* blank line */

         console.log('Checking results of : Seller initiates a contract; Buyer accepts contract; Seller adds fund; Buyer adds fund.');          

         /* Initial assets of principals. */
         let asset_seller_initial   = (parseInt((block.receipts[3].result.expectOk()).replace('u','0')));
         let asset_buyer_initial    = (parseInt((block.receipts[4].result.expectOk()).replace('u','0')));
         let asset_contract_initial = (parseInt((block.receipts[5].result.expectOk()).replace('u','0')));

         /* Check seller balance. Expect initial balance subtracted with sell price. */
         let asset_seller_expected   = (asset_seller_initial - (parseInt((price.replace('u','0')),10)));      /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         let asset_seller_transacted = (parseInt((block.receipts[8].result.expectOk()).replace('u','0')));
         assertEquals(asset_seller_transacted, asset_seller_expected); 

         /* Check buyer balance. Expect initial balance subtracted with 2x buy price. */
         let asset_buyer_expected   = (asset_buyer_initial - ((parseInt((price.replace('u','0')),10)) * 2));  /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         let asset_buyer_transacted = (parseInt((block.receipts[9].result.expectOk()).replace('u','0')));
         assertEquals(asset_buyer_transacted, asset_buyer_expected); 

         /* Check principal contract balance. Expect balance as 3x price amount.  Initial amount should be zero. */
         let asset_contract_expected   = (asset_contract_initial + ((parseInt((price.replace('u','0')),10)) * 3)); 
         let asset_contract_transacted = (parseInt((block.receipts[10].result.expectOk()).replace('u','0')));
         assertEquals(asset_contract_transacted, asset_contract_expected); 

         console.log(' ');  /* blank line */

         console.log('Checking results of : Buyer releases funds from the contract.');          

         /* Check seller balance. Expect initial balance added with sell price. */
         asset_seller_expected   = (asset_seller_initial + (parseInt((price.replace('u','0')),10)));      /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_seller_transacted = (parseInt((block.receipts[12].result.expectOk()).replace('u','0')));
         assertEquals(asset_seller_transacted, asset_seller_expected); 

         /* Check buyer balance. Expect initial balance subtracted with buy price. */
         asset_buyer_expected   = (asset_buyer_initial - (parseInt((price.replace('u','0')),10)));  /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_buyer_transacted = (parseInt((block.receipts[13].result.expectOk()).replace('u','0')));
         assertEquals(asset_buyer_transacted, asset_buyer_expected); 

         /* Check principal contract balance. Expect balance equal to initial amount. Though initial zero. */
         asset_contract_expected   = asset_contract_initial; 
         asset_contract_transacted = (parseInt((block.receipts[14].result.expectOk()).replace('u','0')));
         assertEquals(asset_contract_transacted, asset_contract_expected); 

         console.log(' ');                            /* blank line */
         console.log('Nice. All good in the hood!');
         console.log(' ');                            /* blank line */

    
        /*
        -----------------------------------------------------------------------------------------------------------------   
           SIMULATE AN ESCROW TRANSACTION WITH A MEDIATOR INVOLVED.
        -----------------------------------------------------------------------------------------------------------------
        */

        console.log(' ');
        console.log('-----------------------------------------------------');
        console.log('-- Simulate an escrow transaction with a Mediator. --');          
        console.log('-----------------------------------------------------');            
        console.log(' ');
        
        block = chain.mineBlock([

            Tx.contractCall('better-escrow', 'get-principal-contract', [], seller.address),  
            Tx.contractCall('better-escrow', 'get-balance-seller', [], seller.address),     /* Get initial asset. */
            Tx.contractCall('better-escrow', 'get-balance-buyer',  [], buyer.address),      /* Get initial asset. */          
            Tx.contractCall('better-escrow', 'get-balance-contract',  [], buyer.address),   /* Get initial asset. */          
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
            Tx.contractCall('better-escrow', 'request-mediator', [], buyer.address),               /* Buyer requested for a Mediator */            

            Tx.contractCall('better-escrow', 'mediate-accept', [], mediator.address),              /* Mediator accepted.             */
            Tx.contractCall('better-escrow', 'get-balance-mediator', [], mediator.address),        /* Get updated asset.             */
            Tx.contractCall('better-escrow', 'get-balance-contract', [], mediator.address),        /* Get updated asset.             */
            Tx.contractCall('better-escrow', 'mediator-confirmation-seller', [], seller.address),  /* Seller accepted Mediator.      */
            Tx.contractCall('better-escrow', 'mediator-confirmation-buyer', [], buyer.address),    /* Buyer accepted Mediator.       */   

            Tx.contractCall('better-escrow', 'mediator-decides-good', [], mediator.address),       /* Mediator decides good transaction. */
            Tx.contractCall('better-escrow', 'fund-disburse', [], seller.address),                 /* Seller triggers fund disbursement. */
            Tx.contractCall('better-escrow', 'get-balance-seller', [], seller.address),     /* Get updated asset. */
            Tx.contractCall('better-escrow', 'get-balance-buyer',  [], buyer.address),      /* Get updated asset. */       
            Tx.contractCall('better-escrow', 'get-balance-mediator', [], mediator.address), /* Get updated asset. */   

            Tx.contractCall('better-escrow', 'get-balance-contract', [], seller.address),   /* Get updated asset. */

         ]);

         console.log('seller.address   = ' + seller.address);
         console.log('buyer.address    = ' + buyer.address);
         console.log('mediator.address = ' + mediator.address);
         console.log('get-principal-contract = ' + block.receipts[0].result);

         console.log('price            = ' + price);
         console.log('result count     = ' + block.receipts.length);
          /* assertEquals(block.receipts.length, 20);  /* expected contract call results */

         console.log('get-balance-seller   = ' + block.receipts[1].result);
         console.log('get-balance-buyer    = ' + block.receipts[2].result);
         console.log('mediator.balance     = ' + mediator.balance);  /* account.mediator initial balance. at this point, mediator principal is still NONE */          
         console.log('get-balance-contract = ' + block.receipts[3].result); 

         console.log('bill-create          = ' + block.receipts[4].result + ' --> Seller initiates a bill');
         console.log('bill-accept          = ' + block.receipts[5].result + ' --> Buyer accepts the bill');

         console.log('get-balance-seller   = ' + block.receipts[6].result);
         console.log('get-balance-buyer    = ' + block.receipts[7].result);
         console.log('get-balance-contract = ' + block.receipts[8].result);

         console.log('fund-seller          = ' + block.receipts[9].result + ' --> Seller funded contract');  
         console.log('fund-buyer           = ' + block.receipts[10].result + ' --> Buyer funded contract');

         console.log('get-balance-seller   = ' + block.receipts[11].result);
         console.log('get-balance-buyer    = ' + block.receipts[12].result);
         console.log('get-balance-contract = ' + block.receipts[13].result);
         
         console.log('request-mediator     = ' + block.receipts[14].result + ' --> Seller or buyer requested for a mediator');
         console.log('mediate-accept       = ' + block.receipts[15].result + ' --> Mediator accepted and buys in');

         console.log('get-balance-mediator = ' + block.receipts[16].result);
         console.log('get-balance-contract = ' + block.receipts[17].result);

         console.log('mediator-confirmation-seller = ' + block.receipts[18].result + ' --> Seller approves the mediator');
         console.log('mediator-confirmation-buyer  = ' + block.receipts[19].result + ' --> Buyer approves the mediator');

         console.log('mediator-decides-good = ' + block.receipts[20].result + ' --> Mediator favors the original deal');
         console.log('fund-disburse         = ' + block.receipts[21].result + ' --> Seller triggers fund disbursement');

         console.log('get-balance-seller    = ' + block.receipts[22].result);
         console.log('get-balance-buyer     = ' + block.receipts[23].result);
         console.log('get-balance-mediator  = ' + block.receipts[24].result);
         console.log('get-balance-contract  = ' + block.receipts[25].result + ' --> Contract principal final asset should be zero.');

         console.log(' ');  /* blank line */

         /* ----------------------------------------------------------------------------- */
         console.log('Asserting smart contract function results...');
         /* ----------------------------------------------------------------------------- */

         assertEquals(block.receipts[4].result.expectOk().expectOk(),  '[u1, u0, u0]');  /* bill-create   */
         assertEquals(block.receipts[5].result.expectOk().expectOk(),  '[u1, u1, u0]');  /* bill-accept   */
         assertEquals(block.receipts[9].result.expectOk().expectOk(),  '[u2, u1, u0]');  /* fund-seller   */
         assertEquals(block.receipts[10].result.expectOk().expectOk(),  '[u2, u2, u0]');  /* fund-buyer    */
         assertEquals(block.receipts[14].result.expectOk().expectOk(), '[u2, u2, u1]');  /* request-mediator  */       

         /* Initial assets of principals. */
         asset_seller_initial   = (parseInt((block.receipts[1].result.expectOk()).replace('u','0')));
         asset_buyer_initial    = (parseInt((block.receipts[2].result.expectOk()).replace('u','0')));
         asset_contract_initial = (parseInt((block.receipts[3].result.expectOk()).replace('u','0')));

         /* Check seller balance. Expect initial balance subtracted with sell price. */
         asset_seller_expected   = (asset_seller_initial - (parseInt((price.replace('u','0')),10)));      /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_seller_transacted = (parseInt((block.receipts[11].result.expectOk()).replace('u','0')));
         assertEquals(asset_seller_transacted, asset_seller_expected); 

         /* Check buyer balance. Expect initial balance subtracted with 2x buy price. */
         asset_buyer_expected   = (asset_buyer_initial - ((parseInt((price.replace('u','0')),10)) * 2));  /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_buyer_transacted = (parseInt((block.receipts[12].result.expectOk()).replace('u','0')));
         assertEquals(asset_buyer_transacted, asset_buyer_expected); 

         /* Check principal contract balance. Expect balance as 3x price amount.  Initial amount should be zero. */
         asset_contract_expected   = (asset_contract_initial + ((parseInt((price.replace('u','0')),10)) * 3)); 
         asset_contract_transacted = (parseInt((block.receipts[13].result.expectOk()).replace('u','0')));
         assertEquals(asset_contract_transacted, asset_contract_expected); 

         /* Check seller balance. Expect initial balance added with sell price. */
         asset_seller_expected   = (asset_seller_initial + (parseInt((price.replace('u','0')),10)));      /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_seller_transacted = (parseInt((block.receipts[22].result.expectOk()).replace('u','0')));
         assertEquals(asset_seller_transacted, asset_seller_expected); 

         /* Check buyer balance. Expect initial balance subtracted with buy price. */
         asset_buyer_expected   = (asset_buyer_initial - (parseInt((price.replace('u','0')),10)));  /* Subtract price from initial principal asset. Need to convert string 'uint' into javascript int.  */
         asset_buyer_transacted = (parseInt((block.receipts[23].result.expectOk()).replace('u','0')));
         assertEquals(asset_buyer_transacted, asset_buyer_expected); 


/*
xxxxx add the mediator here. also need the smart contract to give the Mediator's money back lol
*/
         /* Check principal contract balance. Expect balance equal to initial amount. Though initial zero. */
         asset_contract_expected   = asset_contract_initial; 
         asset_contract_transacted = (parseInt((block.receipts[25].result.expectOk()).replace('u','0')));
         assertEquals(asset_contract_transacted, asset_contract_expected); 

         console.log(' ');                            /* blank line */
         console.log('Nice. All good in the hood!');
         console.log(' ');                            /* blank line */

        /*
        -----------------------------------------------------------------------------------------------------------------   
           END OF THE LINE.  PLEASE WATCH THE GAP.
        -----------------------------------------------------------------------------------------------------------------
        */

        console.log(' ');                            /* blank line */
        console.log('Good luck Clarinauts!  May Satoshi\'s force be with you.');
        console.log(' ');                            /* blank line */

       /*
        export interface Account {
         address: string;
         balance: number;
         name: string;
         mnemonic: string;
       ;;  derivation: string;
       }
       */

    },
});
