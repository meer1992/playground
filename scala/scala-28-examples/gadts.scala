package examples

object gadts extends Application {

  abstract class Term[T]
  case class Lit(x: int) extends Term[int]
  case class Succ(t: Term[int]) extends Term[int]
  case class IsZero(t: Term[int]) extends Term[boolean]
  case class If[T](c: Term[boolean],
                   t1: Term[T],
                   t2: Term[T]) extends Term[T]

  def eval[T](t: Term[T]): T = t match {
    case Lit(n)        => n
    case Succ(u)       => eval(u) + 1
    case IsZero(u)     => eval(u) == 0
    case If(c, u1, u2) => eval(if (eval(c)) u1 else u2)
  }
  Console.println(
    eval(If(IsZero(Lit(1)), Lit(41), Succ(Lit(41)))))
}

