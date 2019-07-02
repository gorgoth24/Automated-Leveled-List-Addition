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
    procedure insertnode(inode : EnchNode)//sorted
        while 