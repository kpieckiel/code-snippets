// A polymorphic drawable object that can hold anything that implements a draw function.

#include <iostream>
#include <memory>
#include <string>
#include <utility>
#include <vector>

using std::endl;
using std::vector;
using std::ostream;
using std::string;
using std::cout;
using std::unique_ptr;
using std::reverse;
using std::move;

template <typename T>
void draw(const T& x, ostream& out, size_t position)
{ out << string(position, ' ') << x << endl; }

class my_class_t {
  friend std::ostream& operator<<(std::ostream& out, const my_class_t& point)
  { out << "my_class_t"; return out; }
};

void draw(const my_class_t& x, ostream& out, size_t position)
{ out << string(position, ' ') << "my_class_t" << endl; }

class object_t {
public:
  template <typename T>
  object_t(T x) : self_(new model<T>(move(x)))
  { cout << "ctor: object_t (" << self_ << ")" << endl; }

  object_t(const object_t& x) : self_(x.self_->copy_())
  { cout << "copy: object_t (" << x.self_ << ")" << endl; }

  object_t& operator=(const object_t& x)
  { cout << "asgn: object_t (" << x.self_ << ")" << endl;
    object_t tmp(x); self_ = move(tmp.self_); return *this; }

  object_t& operator=(object_t&& x) noexcept
  { cout << "move: object_t (" << x.self_ << ")" << endl;
  self_ = move(x.self_); x.self_.reset(); return *this; }

  friend void draw(const object_t& x, ostream& out, size_t position)
  { x.self_->draw_(out, position); }

private:
  struct concept_t {
    virtual ~concept_t() = default;
    virtual concept_t* copy_() const = 0;
    virtual void draw_(ostream&, size_t) const = 0;
  };

  template <typename T>
  struct model : concept_t {
    model(T x) : data_(move(x))
    { cout << "ctor: model (" << data_ << ")" << endl; }

    concept_t* copy_() const
    { cout << "copy_ model (" << (*this).data_ << ")" << endl;
      return new model(*this); }

    void draw_(ostream& out, size_t position) const
    { draw(data_, out, position); }

    T data_;
  };

  unique_ptr<concept_t> self_;
};

using document_t = vector<object_t>;

void draw(const document_t& x, ostream& out, size_t position)
{
  out << string(position, ' ') << "<document>" << endl;
  for (const auto& e : x) draw(e, out, position + 2);
  out << string(position, ' ') << "</document>" << endl;
}

//object_t func()
//{
//  object_t result = 5;
//  return result;
//}

int main()
{
  document_t document;
  document.reserve(5);

  document.emplace_back(0);
  document.emplace_back(string("Hello!"));
  document.emplace_back(2);
  document.emplace_back(my_class_t());

  //reverse(document.begin(), document.end());
  
  draw(document, cout, 0);
}
