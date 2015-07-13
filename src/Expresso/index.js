var expressoParser = require("Expresso.Parser");
var Data = require("Expresso.Parser.Data");
var Operators = require("Expresso.Operations");

expressionOperator = function(operator) {
    return function(left, expressionForRight) {
        var right = expressionForRight.rawExpression;

        return operator(left)(right);
    };
};

function Expression(value) {
    this.rawExpression = value;
    
    this.and = function(expression) {
        var andF = expressionOperator(Operators.expressionAnd);
        var andedResult = andF(value, expression);
        
        return new Expression(andedResult);
    };

    this.or = function(expression) {
        var orF = expressionOperator(Operators.expressionOr);
        var oredResult = orF(value, expression);
        
        return new Expression(oredResult);
    };
    
    this.replacePlaceholderWith = function(expression) {
        var replacedValue = Operators.replacePlaceholder(value)(expression.rawExpression);

        if(replacedValue.value0) return new Expression(replacedValue.value0);

        return undefined;
    };
    
    this.toString = function() { return Data.expressionShow.show(value); };
};

var parse = function(incoming) {
    var parse = expressoParser.parseExpressoExpression(incoming);

    if(parse.value0) return new Expression(parse.value0);

    return undefined;    
};

exports.parse = parse;
