implementation
type
    cEnchNode = class(node)


    
private
    FormId : Cardinal;
    EnchCost : integer;
public
    constructor create(iFormId : Cardinal, iEnchCost : Integer);
        EnchCost := iEnchCost;
        FormId := iFormId;
    end;
    //getters
    function getFormId()Cardinal;
        result := FormId;
    end;
    function getEnchCost()Integer;
        result := EnchCost;
    end;