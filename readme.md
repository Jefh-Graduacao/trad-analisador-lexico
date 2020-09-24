# 👩‍💻 Analisador Léxico

Analisador léxico desenvolvido usando Flex para a disciplina de tradutores (2020/2).

O objetivo do analisador é reconhecer alguns tokens de uma pseudolinguagem baseada em C. Todo o código que o analisador precisa reconhecer está no arquivo `input.c`.

O código fonte gerado pelo Flex está no arquivo `lex.yy.c`.

## Instruções de uso

Para gerar o código C a apartir das regras no arquivo Flex:

```bash
flex analisador.lex
```

Para compilar o código C e executar o analisador:

```bash
gcc lex.yy.c -o analisador

./analisador
```
