def eliminate_left_recursion(grammar):
    non_terminals = list(grammar.keys())
    for i in range(len(non_terminals)):
        A_i = non_terminals[i]
        for j in range(i):
            A_j = non_terminals[j]
            new_productions = []
            for prod in grammar[A_i]:
                if prod.startswith(A_j):
                    for A_j_prod in grammar[A_j]:
                        new_productions.append(A_j_prod + prod[len(A_j):])
                else:
                    new_productions.append(prod)
            grammar[A_i] = new_productions

        direct_recursion_removed = remove_direct_left_recursion(A_i, grammar[A_i])
        grammar.update(direct_recursion_removed)
        # print("\n")
        # for non_terminal, productions in grammar.items():
        #     print(f"{non_terminal} -> {' | '.join(productions)}")
        # print("\n")
    return grammar

def remove_direct_left_recursion(non_terminal, productions):
    alpha = []
    beta = []
    new_productions = []

    for prod in productions:
        if prod.startswith(non_terminal):
            alpha.append(prod[len(non_terminal):])
        else:
            beta.append(prod)

    if not alpha:
        return {non_terminal: productions}

    new_non_terminal = non_terminal + "'"
    for b in beta:
        new_productions.append(b + new_non_terminal)

    alpha_productions = [a + new_non_terminal for a in alpha]
    alpha_productions.append('epsilon')

    return {
        non_terminal: new_productions,
        new_non_terminal: alpha_productions
    }

def left_factoring(grammar):
    new_grammar = {}
    for non_terminal, productions in grammar.items():
        prefixes = {}
        for production in productions:
            prefix = production[0] 
            if prefix in prefixes:
                prefixes[prefix].append(production)
            else:
                prefixes[prefix] = [production]

        if len(prefixes) > 1 or any(len(prods) > 1 for prods in prefixes.values()):
            new_productions = []
            for prefix, prods in prefixes.items():
                if len(prods) > 1:
                    new_non_terminal = non_terminal + "f"
                    new_productions.append(prefix + new_non_terminal)
                    new_grammar[new_non_terminal] = [prod[1:] if len(prod) > 1 else 'epsilon' for prod in prods]
                else:
                    new_productions.extend(prods)
            new_grammar[non_terminal] = new_productions
        else:
            new_grammar[non_terminal] = productions
    
    return new_grammar

grammar = {
    # 'A' : ['BC', 'a'],
    # 'B': ['CA', 'Ab'],
    # 'C': ['AB', 'CC', 'a']
    'S': ['SiEtS', 'SiEtSeS', 'a'],
    'E': ['b']
}

print("Original Grammar:")
print(grammar)

print("\nGrammar after eliminating left recursion:")
grammar_no_left_recursion = eliminate_left_recursion(grammar)
for non_terminal, productions in grammar_no_left_recursion.items():
    print(f"{non_terminal} -> {' | '.join(productions)}")

print("\nFinal Grammar after left factoring:")
final_grammar = left_factoring(grammar_no_left_recursion)
for non_terminal, productions in final_grammar.items():
    print(f"{non_terminal} -> {' | '.join(productions)}")
