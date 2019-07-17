implementation

type
    EnchantmentSkipList = class()
    
private
    masterladder : levellist;
    
    
    function coinflip()boolean;//used in determining height
    begin
        if 
            (randomrange(1, 2) = 1) then := true //tails
        end else 
            result := false //heads
        end;
    end;
    
    function insertbase(iFormId : cardinal, passedNode : lnode)boolean;
    var
        coinflip : boolean;
        insertionNode : bEnchNode;
        NewNode : lnode;
    begin
        if not passedNode.getnext() = nil then begin//level continues
            if passedNode.getnext.getEnchNode().getFormId() < iFormId then begin//move down or place node
                if passedNode.getdown() = nil then begin //level 0, place node
                    insertionNode := bEnchNode.create(iFormId, passedNode.getnext());//create basenode
                    NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                    NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                    passedNode.setnext(NewNode);//give the current node the pointer to the new one
                    result := coinflip();//determine if next level should be built
                end else begin //level n, move down
                    coinflip := insertbase(iFormId, passedNode.getdown());//move down a node
                    if coinflip then begin//add level if prev. was added and told to add a level
                        while not passedNode.getdown().getNext().getEnchNode().getFormId() = iFormID do //move lateral until insertion point is found for level
                            passedNode := passedNode.getdown().getNext();
                        end;
                        insertionNode := passedNode.getdown().getNext().getEnchNode();//get node
                        insertionNode.getlevels().addlevel();//increase height
                        NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                        NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                        passedNode.setnext(NewNode);//give the current node the pointer to the new one
                        result := coinflip();//determine if next level should be built
                    end else begin
                        result := false;//no more levels as this one wans't built
                    end;
                end;
            end else begin//move right
                insertbase(iFormId, passedNode.getnext());
            end;
        end else begin//end of level, must move down or insert 
            if passedNode.getdown() = nil then begin //level n, move down
                coinflip := insertbase(iFormId, passedNode.getdown());//move down
                if coinflip then begin//add level if prev. was added and told to add a level
                    insertionNode := passedNode.getdown().getNext().getEnchNode();//get node
                    insertionNode.getlevels().addlevel();//increase height
                    NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                    NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                    passedNode.setnext(NewNode);//give the current node the pointer to the new one
                    result := coinflip();//determine if next level should be built
                end else begin
                    result := false;//no more levels as this one wasn't built
                end;
            end else begin//level 0, place node
                insertionNode := bEnchNode.create(iFormId, passedNode.getnext());//create basenode
                passedNode.setnext(insertionNode.getlevels().gethead())//give the current node the pointer to the new one
                result := coinflip();//return value to determine if next level up is built
            end;
        end;
    end;
    
    function insertchild(iFormId : cardinal, iEnchCost : integer)boolean;
    
public

    constructor create();
        masterladder := levellist.create(nil, nil);
    end;
     
    procedure insert(IInterface);
    var
        coindflip := boolean;
        tmp := lnode;
    begin
        if not {base} = nil then 
            coinflip := insertbase({path to form id}, masterladder.gethead().getNext());
            while coinflip do//keep building up past the prev. master ladder height
                insertionNode := masterladder.gethead().getdown().getNext().getEnchNode();//get node
                insertionNode.getlevels().addlevel();//increase height
                masterladder.addlevel();//increase height of ladder
                masterladder.gethead().setnext(insertionNode.getlevels().gethead());//assgin the ladder to the new level node
                coinflip := coinflip();//determine if next level should be built
            end;
        end else 
            insertchild({path to base form id}, {path to EnchCost});
    end;
    
    
    //TODO
    procedure processEnchantments()
        i : lnode;
    begin
        i := masterladder.getL0();
        while not i.getnext() = nil begin
            i := i.getnext();
            {lookup IInterface by formID}
            {check refrenced by}
            {if refrenced by non armor or weap}
                {set FormID to Null}
            {else}
                {if refrenced by armor, iterate and find slots}
        end;
    end;