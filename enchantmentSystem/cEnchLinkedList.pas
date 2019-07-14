implementation
 
uses
    linkedlist
implementation
    EnchLinkedList = class(linkedlist)
    
constructor EnchLinkedList(firstnode : cEnchNode);
    head := firstnode;
    tail := firstnode;
end;

public
    procedure insertnode(inode : cEnchNode)//sorted
    var
        cNode : cEnchNode; //current node
    begin
        cNode := head;
        //check tail(most likely case)
        if inode.getEnchCost() > tail.getEnchCost() then begin
            tail.setnext(cEnchNode);
            tail := iNode;
        //check head
        end else if inode.getEnchCost() < head.getEnchCost() then begin
            inode.setnext(head);
            head := inode;
       //check other nodes no need fo null check since tail is checked above
       //if ench cost is the same it will be placed after the match
        end else begin
            //find Node to insert to
            while inode.getEnchCost() < cNode.getNext.getEnchCost() do
                cNode := cNode.getNext();
            end;
            //insert
            iNode.setNext(cNode.getNext());
            cNode.setNext(iNode);
        end;
     end;
     
     