implementation
type
    cEnchNode = class(node)
private
    FormId : Cardinal;
public
    function getFormId()Cardinal;
        result := FormId;
    end;
    