
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.14.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "test function : (define-read-only (about))",
    async fn(chain: Chain, accounts: Map<string, Account>) {

        /* Assign wallets to be used for simulating the escrow participants - seller, buyer, mediator. */
        let seller    = accounts.get('wallet_9')!;
        let buyer     = accounts.get('wallet_8')!;
        let mediator  = accounts.get('wallet_7')!;

        let block = chain.mineBlock([
           Tx.contractCall('better-escrow', 'about', [], seller.address),
        ]);
        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result.expectOk(), '"better escrow is the escrow.com killer"');
        /* assertEquals(block.receipts[0], "(ok (ok [u1, u0, u0]))"); *?
        /* assertEquals(block.height, 2); */
    },
});
