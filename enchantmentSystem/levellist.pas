implementation'
//l7->l6->l5->l4->l3->l2->l1->10(tail/base)
type
    levellist : class()
private
    L0 : lnode;
    head : lnode;
    height : integer;
public
    
    constructor create(FormID : cardinal);
    var
        l0node : lnode;
    begin
        L0 := firstnode.create(FormID);
        head := lnode;
        height := 0;
    end;
    //add another level
    procedure addnode(FormID : cardinal);
    begin
        height := height + 1;
        head := lnode.create(FormID);
    end;
    
    //getters
    function getheight()integer;
    begin
        result := height;
    end;
    function getNextAtL0()lnode;
        result := tail.next();
    end;
    
    function getnextAtLgiven()lnode;
        result := head.next()
    end;
    