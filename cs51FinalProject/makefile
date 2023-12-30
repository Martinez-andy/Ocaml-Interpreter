all: expr miniml evaluation tests

expr: expr.ml
	ocamlbuild -use-ocamlfind expr.byte

miniml: miniml.ml
	ocamlbuild -use-ocamlfind miniml.byte

evaluation: evaluation.ml
	ocamlbuild -use-ocamlfind evaluation.byte

tests: tests.ml
	ocamlbuild -use-ocamlfind tests.byte

clean:
	rm -rf _build.byte*