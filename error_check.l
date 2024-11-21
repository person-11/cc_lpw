%{
    variable declaration    
%}
%token IF ID NUM 
%%
    SS: SS S
      | S
    S: E ':'
      | IFST
    IFST : IF '(' E ')' S
    E:E '+' T
     |E '-' T
     |T
    T: IDD
     | NUM
     | '(' E ')'
%%

%%
void yyerror(char *str)
{
  printf("syntax error\n");
}
