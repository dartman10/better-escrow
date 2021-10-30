# better-escrow
 
 Just Another Escrow App

 Powered by Stacks

<code class="language-mermaid">

<!DOCTYPE html>
<html lang="en">
   <head>
	 <script src="https://cdnjs.cloudflare.com/ajax/libs/mermaid/8.0.0/mermaid.min.js"></script>
    </head>

<body>
 <pre>

<a href="https://mermaid.live/view/#eyJjb2RlIjoic3RhdGVEaWFncmFtLXYyXG4gICAgWypdIC0tPiBEb3JtYW50XG4gICAgRG9ybWFudCAtLT4gU2VsbGVyX0luaXRpYXRlZFxuICAgIFNlbGxlcl9Jbml0aWF0ZWQgLS0-IEJ1eWVyX0FjY2VwdGVkXG4gICAgQnV5ZXJfQWNjZXB0ZWQgLS0-IFNlbGxlcl9Cb3VnaHRfSW5cbiAgICBTZWxsZXJfQm91Z2h0X0luIC0tPiBCdXllcl9Cb3VnaHRfSW5cbiAgICBCdXllcl9Cb3VnaHRfSW4gLS0-IEJ1eWVyX2lzX0hhcHB5XG4gICAgQnV5ZXJfaXNfSGFwcHkgLS0-IFsqXVxuICAgICAgICAgICAgIiwibWVybWFpZCI6IntcbiAgXCJ0aGVtZVwiOiBcImRlZmF1bHRcIlxufSIsInVwZGF0ZUVkaXRvciI6dHJ1ZSwiYXV0b1N5bmMiOnRydWUsInVwZGF0ZURpYWdyYW0iOnRydWV9">asdf</a>
 
 <code class="language-mermaid">
 graph TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]

</code>
</pre>

<div class="mermaid">graph LR


graph TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]
A--&gt;B  
</div>
	

graph TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]
  

</body>
<script>
var config = {
    startOnLoad:true,
    theme: 'forest',
    flowchart:{
            useMaxWidth:false,
            htmlLabels:true
        }
};
mermaid.initialize(config);
window.mermaid.init(undefined, document.querySelectorAll('.language-mermaid'));
</script>

graph TD
    A[Christmas] -->|Get money| B(Go shopping)
    B --> C{Let me think}
    C -->|One| D[Laptop]
    C -->|Two| E[iPhone]
    C -->|Three| F[fa:fa-car Car]
  

</html>


stateDiagram-v2
    asdf --> Dormant
    Dormant --> Seller_Initiated
    Seller_Initiated --> Buyer_Accepted
    Buyer_Accepted --> Seller_Bought_In
    Seller_Bought_In --> Buyer_Bought_In
    Buyer_Bought_In --> Buyer_is_Happy
    Buyer_is_Happy --> [*]
            
sequenceDiagram
    Seller->>+Buyer: seller sends an invoice
    Buyer->>+Seller: buyer accepts terms of invoice
    Seller->>+Buyer: seller puts up collateral
    Buyer->>+Seller: buyer puts up collateral
    Seller->>+Buyer: seller delivers product
    Buyer->>+Seller: buyer receives and releases payment

       /*
        export interface Account {
         address: string;
         balance: number;
         name: string;
         mnemonic: string;
       ;;  derivation: string;
       }
       */

            