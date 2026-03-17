class Stack {
  int elemNum;
  List<dynamic> stack = [];

  Stack(this.elemNum);

  void showTop() {
    if (stack.isNotEmpty) {
      print(stack.last);
    } else {
      print("Stack vazia");
    }
  }

  void showStack() {
    print(stack);
  }

  void push(dynamic elem) {
    if (stack.length < elemNum) {
      stack.add(elem);
      print(stack);
    } else {
      print("Stack cheia");
    }
  }

  void pop() {
    if (stack.isNotEmpty) {
      stack.removeLast();
      print(stack);
    } else {
      print("Stack vazia");
    }
  }
}

void main() {
  Stack myStack = Stack(10);

  for (int i = 0; i < 10; i++) {
    myStack.push(i);
  }

  myStack.showTop();
  myStack.pop();
  myStack.showStack();
}