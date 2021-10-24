
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Testing better-escrow / Just Another Escrow App",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        /* Assign wallets to be used for simulating the escrow participants - seller, buyer, mediator. */
        let seller    = accounts.get('wallet_9')!;
        let buyer     = accounts.get('wallet_8')!;
        let mediator  = accounts.get('wallet_7')!;

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
            Tx.contractCall('better-escrow', 'bill-create',  [], seller.address),
            Tx.contractCall('better-escrow', 'bill-accept',  [], buyer.address),
            Tx.contractCall('better-escrow', 'fund-seller',  [], seller.address),
            Tx.contractCall('better-escrow', 'fund-buyer',   [], buyer.address),
            Tx.contractCall('better-escrow', 'fund-release', [], buyer.address),
         ]);
         assertEquals(block.receipts.length, 5);
         assertEquals(block.receipts[0].result.expectOk().expectOk(), '[u1, u0, u0]');
         assertEquals(block.receipts[1].result.expectOk().expectOk(), '[u1, u1, u0]');
         assertEquals(block.receipts[2].result.expectOk().expectOk(), '[u2, u1, u0]');
         assertEquals(block.receipts[3].result.expectOk().expectOk(), '[u2, u2, u0]');
         assertEquals(block.receipts[4].result.expectOk().expectOk(), '[u2, u3, u0]');


    },
});
