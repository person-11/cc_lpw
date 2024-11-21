#include <bits/stdc++.h>
using namespace std;

struct ASTNode {
    string value;
    ASTNode* left;
    ASTNode* right;
    ASTNode(string val) : value(val), left(nullptr), right(nullptr) {}
};

vector<string> registers = {"R0", "R1", "R2", "R3"};
int reg_count = 0;

string getReg() {
    if (reg_count < registers.size())
        return registers[reg_count++];
    else
        throw runtime_error("Out of registers!");
}

void releaseReg() {
    if (reg_count > 0)
        reg_count--;
}

int precedence(char op) {
    if (op == '+' || op == '-')
        return 1;
    if (op == '*' || op == '/')
        return 2;
    if (op == '^')
        return 3;
    return 0;
}

// assembly code from three-address code (TAC)
vector<string> generate_assembly_code(const vector<string> &tac) {
    vector<string> assembly;
    unordered_map<string, string> var_to_reg;

    for (const string &line : tac) {
        istringstream ss(line);
        string temp_var, equal_sign, operand1, op, operand2;

        ss >> temp_var >> equal_sign >> operand1;
        if (ss >> op >> operand2) {  // Binary operation
            string reg1 = (var_to_reg.count(operand1) ? var_to_reg[operand1] : getReg());
            var_to_reg[operand1] = reg1;
            assembly.push_back("MOV " + reg1 + ", " + operand1);

            string reg2 = (var_to_reg.count(operand2) ? var_to_reg[operand2] : getReg());
            var_to_reg[operand2] = reg2;
            assembly.push_back("MOV " + reg2 + ", " + operand2);

            if (op == "+")
                assembly.push_back("ADD " + reg1 + ", " + reg2);
            else if (op == "-")
                assembly.push_back("SUB " + reg1 + ", " + reg2);
            else if (op == "*")
                assembly.push_back("MUL " + reg1 + ", " + reg2);
            else if (op == "/")
                assembly.push_back("DIV " + reg1 + ", " + reg2);

            var_to_reg[temp_var] = reg1;
            releaseReg();
        } else {  // Unary operation or assignment
            string reg = getReg();
            var_to_reg[temp_var] = reg;
            assembly.push_back("MOV " + reg + ", " + operand1);
        }
    }
    return assembly;
}

// validate syntax
bool is_valid_expression(const string &expression) {
    int open_parens = 0;
    bool last_was_operator = true;
    for (size_t i = 0; i < expression.length(); ++i) {
        char ch = expression[i];
        if (isalnum(ch)) {
            last_was_operator = false;
        } else if (ch == '(') {
            open_parens++;
            last_was_operator = true;
        } else if (ch == ')') {
            open_parens--;
            if (open_parens < 0) {
                cout << "Error: Mismatched parentheses\n";
                return false;
            }
            last_was_operator = false;
        } else if (ch == '+' || ch == '-' || ch == '*' || ch == '/' || ch == '^') {
            if (last_was_operator && ch != '-' && ch != '+') {
                cout << "Error: Unexpected binary operator\n";
                return false;
            }
            last_was_operator = true;
        } else {
            cout << "Error: Invalid character in expression\n";
            return false;
        }
    }
    if (open_parens != 0) {
        cout << "Error: Mismatched parentheses\n";
        return false;
    }
    if (last_was_operator) {
        cout << "Error: Expression ends with an operator\n";
        return false;
    }
    return true;
}

vector<string> infix_to_postfix(const string &expression) {
    stack<char> op_stack;
    vector<string> output;
    bool unary_flag = false;

    for (size_t i = 0; i < expression.length(); ++i) {
        char ch = expression[i];
        if (isalnum(ch)) {
            string operand(1, ch);
            if (unary_flag) {
                operand = "-" + operand;
                unary_flag = false;
            }
            output.push_back(operand);
        } else if (ch == '(') {
            op_stack.push(ch);
        } else if (ch == ')') {
            while (!op_stack.empty() && op_stack.top() != '(') {
                output.push_back(string(1, op_stack.top()));
                op_stack.pop();
            }
            op_stack.pop();
        } else {
            if (ch == '-' && (i == 0 || expression[i - 1] == '(' || !isalnum(expression[i - 1]))) {
                unary_flag = true;
            } else {
                while (!op_stack.empty() && precedence(op_stack.top()) >= precedence(ch)) {
                    output.push_back(string(1, op_stack.top()));
                    op_stack.pop();
                }
                op_stack.push(ch);
            }
        }
    }

    while (!op_stack.empty()) {
        output.push_back(string(1, op_stack.top()));
        op_stack.pop();
    }
    return output;
}

pair<vector<string>, ASTNode*> generate_three_address_code_with_ast(const vector<string> &postfix) {
    int temp_counter = 1;
    stack<ASTNode*> node_stack;
    vector<string> tac;

    for (const string &token : postfix) {
        if (isalnum(token[0])) {
            node_stack.push(new ASTNode(token));
        } else if (token[0] == '-' && token.size() > 1) {  // Unary minus
            string temp_var = "t" + to_string(temp_counter++);
            tac.push_back(temp_var + " = " + token);
            node_stack.push(new ASTNode(temp_var));
        } else {
            ASTNode* right = node_stack.top(); node_stack.pop();
            ASTNode* left = node_stack.top(); node_stack.pop();
            string temp_var = "t" + to_string(temp_counter++);
            
            tac.push_back(temp_var + " = " + left->value + " " + token + " " + right->value);
            
            ASTNode* op_node = new ASTNode(token);
            op_node->left = left;
            op_node->right = right;
            
            node_stack.push(op_node);
        }
    }

    ASTNode* root = node_stack.top();
    node_stack.pop();
    
    tac.push_back("x = " + root->value);

    return {tac, root};
}

void printAST(ASTNode* node, int depth = 0) {
    if (node == nullptr) return;
    for (int i = 0; i < depth; i++) cout << "  ";
    cout << node->value << endl;
    printAST(node->left, depth + 1);
    printAST(node->right, depth + 1);
}

int main() {
    string expression;
    cout << "Enter the expression: ";
    getline(cin, expression);

    if (!is_valid_expression(expression)) {
        cout << "Error: Invalid expression" << endl;
        return 1;
    }

    vector<string> postfix = infix_to_postfix(expression);

    vector<string> tac;
    ASTNode* ast_root;
    tie(tac, ast_root) = generate_three_address_code_with_ast(postfix);

    cout << "Three-Address Code:" << endl;
    for (const string &line : tac) {
        cout << line << endl;
    }

    vector<string> assembly = generate_assembly_code(tac);

    cout << "\nAssembly Code:" << endl;
    for (const string &line : assembly) {
        cout << line << endl;
    }

    cout << "\nAbstract Syntax Tree (AST):" << endl;
    printAST(ast_root);

    return 0;
}
