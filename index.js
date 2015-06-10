var expressoParser = require('Expresso.Parser');
var Prelude = require('Prelude');
var Data = require('Expresso.Parser.Data');
var Operators = require('Expresso.Operators');

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
        Operators.replacePlaceholderWith(expression.rawExpression)(value).value0;
    }
    
    this.toString = function() { return Data.expressionShow.show(value); };
}

function Expresso() {
    this.parseExpression = function(incoming) {
        var parse = expressoParser.parseExpressoExpression(incoming);

        return new Expression(parse.value0);
    };
};

global.Expresso = new Expresso();
