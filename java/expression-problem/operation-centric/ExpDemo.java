public class ExpDemo {
  public static void main(String[] args) {
    Exp e = new Add(new Lit(2),new Lit(3));
    e.accept(new PrintVisitor());
    System.out.println();
  }
}
