implementation
//l7->l6->l5->l4->l3->l2->l1->10(tail/base)
type
    levellist : class()
private
    L0 : lnode;
    head : lnode;
public
    
    constructor create(inode : bEnchNode, inext : lnode);
    begin
        L0 := lnode.create(inode);
        head := L0;
        head.setnext(inext);
    end;
    
    procedure addlevel();
    var
        new : lnode;
    begin
        new := lnode.create(head.getnode());
        new.setdown(head);
        new.setnext();
        head := new;
    end;
    
    //getters
    function getNextAtL0()lnode;
        result := L0.next();
    end;
    