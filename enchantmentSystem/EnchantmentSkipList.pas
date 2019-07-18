implementation

type
    EnchantmentSkipList = class()
    
private
    masterladder : levellist;
    amortail, weapontail : lnode;
    
    
    
    function coinflip()boolean;//used in determining height
    begin
        if 
            (randomrange(1, 2) = 1) then := true //tails
        end else 
            result := false //heads
        end;
    end;
    
    function insertbase(iFormId : cardinal, iEnch : IInterface, passedNode : lnode, child : IInterface)boolean;
    var
        coinflip : boolean;
        insertionNode : bEnchNode;
        NewNode : lnode;
    begin
        if not passedNode.getnext() = nil then begin//level continues
            if passedNode.getnext().getEnchNode().getFormId() = iFormId then begin//node already added (child was called before base and added it)
                result := false;
            end else if passedNode.getnext().getEnchNode().getFormId() < iFormId then begin//move down or place node
                if passedNode.getdown() = nil then begin //level 0, place node
                    insertionNode := bEnchNode.create(iFormId, iEnch);//create basenode
                    if not child = nil then begin
                        insertionNode.addChild(child);
                    end;
                    NewNode := insertionNode.getlevels().gethead();//assign top level of insertionNode to Newnode
                    NewNode.setnext(passedNode.getNext());//give the new node the correct pointer
                    passedNode.setnext(NewNode);//give the current node the pointer to the new one
                    result := coinflip();//determine if next level should be built
                end else begin //level n, move down
                    coinflip := insertbase(iFormId, iEnch, passedNode.getdown(), child);//move down a node
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
                insertbase(iFormId, iEnch, passedNode.getnext(), child);
            end;
        end else begin//end of level, must move down or insert 
            if passedNode.getdown() = nil then begin //level n, move down
                coinflip := insertbase(iFormId, iEnch, passedNode.getdown(), child);//move down
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
                insertionNode := bEnchNode.create(iFormId, iEnch);//create basenode
                if not child = nil then begin
                    insertionNode.addChild(child);
                end;
                passedNode.setnext(insertionNode.getlevels().gethead())//give the current node the pointer to the new one
                result := coinflip();//return value to determine if next level up is built
            end;
        end;
    end;
    
    function insertchild(iFormId : cardinal, passedNode : lnode, iNode : cEnchNode)boolean;
    begin
        if not passedNode.getnext() = nil then begin//level continues
             if passedNode.getnext().getEnchNode().getFormId() = iFormId then begin//is correct node, insert
                passedNode.getnext().getEnchNode().addChild(iNode);
                result := true;
             end else if passedNode.getnext().getEnchNode().getFormId() < iFormId then begin//is greater, move down
                if passedNode.getdown() = nil then begin//at L0, node not found
                    result := false;
                end else begin//move down
                    result := insertchild(iFormID, passedNode.getdown(), iNode);
             end else//is less, move right
                result := insertchild(iFormID, passedNode.getnext(), iNode);
        end else begin//end of level must move down
            if passedNode.getdown() = nil then begin//at L0, node not found
                result := false;
            end else begin//move down
                result := insertchild(iFormID, passedNode.getdown(), iNode);
            end;
        end;
    end;
public

    constructor create();
        masterladder := levellist.create(nil, nil);
    end;
     
    procedure insert(iEnch : IInterface);
    var
        coinflip,basefound : boolean;
        tmp : lnode;
        child : cEnchNode;
    begin
        if not iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')) = nil then 
            coinflip := insertbase(GetLoadOrderFormID(iEnch), iEnch, masterladder.gethead(), nil);
            while coinflip do//keep building up past the prev. master ladder height
                insertionNode := masterladder.gethead().getdown().getNext().getEnchNode();//get node
                insertionNode.getlevels().addlevel();//increase height
                masterladder.addlevel();//increase height of ladder
                masterladder.gethead().setnext(insertionNode.getlevels().gethead());//assign  the ladder to the new level node
                coinflip := coinflip();//determine if next level should be built
            end;
        end else
            child := cEnchNode.create(iEnch, iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Enchantment Cost')));
            basefound := insertchild(iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')), masterladder.gethead(), child);
            if not basefound then begin
                insertbase(iEnch.getNativeValue(ElementByPath(selectedRecord, 'ENIT\Base Enchantment')), iEnch, masterladder.gethead(), child);
            end;
        end;
    end;
    
    //TODDO: ARMOR SLOT STRORAGE
    //       see if I need to store weapon types
    //removes non true bases and stores information on the types of items the bases are applied to
    procedure prepareEnchantments()
        i, count : integer;
        current, next : lnode;
        ench, ref : IInterface;
        AlvlInit, WlvlInit : boolean;
    begin
        AlvlInit := False;
        WlvlInit := False;
        masterladder.sethead(nil);//not needed anymore as data will be processed sequentualy and not looked up
        masterladder.addlevel();//L1, Weapon level
        weapontail := masterladder.gethead();
        masterladder.addlevel();//L2, Armor level
        armortail := masterladder.gethead();
        current := masterladder.getL0();
        while not current.getnext() = nil begin
            next := current.getnext();
            ench := next.getEnchNode().getEnch();
            ench.getlevels().sethead(nil);//not needed anymore as data will be processed sequentualy and not looked up
            count := ReferencedByCount(ench);
            While i <= count do
                ref := ReferencedByIndex(ench, i)
                if Signature(ref) = 'ARMO' then begin
                    if not WlvlInit and not AlvlInit then begin//Weaponlvl and AlvlInit DNE
                        next.getEnchNode().getlevels().addlevel();//build to L2(1/2)
                        next.getEnchNode().getlevels().addlevel();//build to L2(2/2)
                        AlvlInit := True;
                    end else if not AlvlInit then begin//Weaponlvl Exists and AlvlInit DNE
                        next.getEnchNode().getlevels().addlevel();//build to L2
                        AlvlInit := True;
                    end;
                    armortail.setnext(next.getEnchNode().getlevels().gethead());//link node
                    armortail := amortail.getnext();//set tail
                end if Signature(ref) = 'WEAP' else begin
                    if not AlvlInit and not WlvlInit then begin//Weaponlvl and AlvlInit DNE
                        next.getEnchNode().getlevels().addlevel();//Build to L1
                        weapontail.setnext(next.getEnchNode().getlevels().gethead());
                        weapontail := weapontail.getnext();//set tail
                        WlvlInit := False;
                    end else if not AlvlInit then begin//Weaponlvl DNE and Armorlvl Exists 
                        weapontail.setnext(next.getEnchNode().getlevels().gethead().getdown());
                        weapontail := weapontail.getnext();//set tail
                        WlvlInit := False;
                    end else if not WlvlInit then begin//Weaponlvl Exists and Armorlvl DNE
                        weapontail.setnext(next.getEnchNode().getlevels().gethead());
                        weapontail := weapontail.getnext();//set tail
                    end;
                end;
            end;
            if not AlvlInit or WlvlInit then//neither an armor or weap ench.
                current.setnext(next.getnext());//delete node
            end;
            current := next;
            i := i + 1;
        end;
    end;
    