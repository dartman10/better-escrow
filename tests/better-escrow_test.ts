
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
        assertEquals(block.receipts[0].result.expectOk(), '"better escrow is the escrow.com killer"');
        assertEquals(block.receipts[1].result.expectOk(), '[u0, u0, u0]');

        /*
        ------------------------------------------------------------ 
           Simulate a smooth escrow transaction.                      
        ------------------------------------------------------------- 
        */
        block = chain.mineBlock([
            Tx.contractCall('better-escrow', 'bill-create',  [price], seller.address),
            Tx.contractCall('better-escrow', 'bill-accept',  [], buyer.address),
            Tx.contractCall('better-escrow', 'fund-seller',  [], seller.address),
            Tx.contractCall('better-escrow', 'get-balance-seller', [], seller.address),
            Tx.contractCall('better-escrow', 'fund-buyer',   [], buyer.address),
            Tx.contractCall('better-escrow', 'get-balance-buyer', [], seller.address),
         /* Tx.contractCall('better-escrow', 'fund-release', [], buyer.address),
         */
            
         ]);

         console.log(seller.address);
         console.log(buyer.address);

         console.log(block.receipts.length);
         / *assertEquals(block.receipts.length, 5); */
         
         console.log(block.receipts[0].result.expectOk().expectOk());
         assertEquals(block.receipts[0].result.expectOk().expectOk(), '[u1, u0, u0]');
         
         console.log(block.receipts[1].result.expectOk().expectOk());
         assertEquals(block.receipts[1].result.expectOk().expectOk(), '[u1, u1, u0]');

         console.log(block.receipts[2].result.expectOk().expectOk());
         assertEquals(block.receipts[2].result.expectOk().expectOk(), '[u2, u1, u0]');

         /* Compare seller balance. Expect initial balance subtracted with sell price. */
         let txt1 = 'u100';
         console.log(parseInt((txt1.replace('u','0')),10));
         /* console.log(parseInt('u99',10));
         u99,999,999,990,000
         */

         console.log(block.receipts[3].result);
         console.log(block.receipts[3].result.expectOk());
         console.log((block.receipts[3].result.expectOk()).replace('u','0'));
         console.log(100000000000000 - (parseInt((price.replace('u','0')),10)));
         /* assertEquals((block.receipts[3].result.expectOk()), (100000000000000 - 1000)); */
         /* assertEquals((block.receipts[3].result.expectOk()), (100000000000000 - (parseInt((price.replace('u','0')),10)))); */
         assertEquals((parseInt((block.receipts[3].result.expectOk()).replace('u','0'))), (100000000000000 - (parseInt((price.replace('u','0')),10)))); 

         /* console.log(block.receipts[3].result.expectOk().expectOk()); */
         /* assertEquals(block.receipts[3].result.expectOk().expectOk(), '[u2, u2, u0]'); */
         /*
         console.log(block.receipts[4].result.expectOk().expectOk());
         assertEquals(block.receipts[4].result.expectOk().expectOk(), '[u2, u3, u0]');
         */

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
