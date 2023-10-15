// How do you turn a unique pointer for a base class into a unique pointer for its derived class?

// If they are polymorphic types and you only need a pointer to the derived type use dynamic_cast:
Derived *derivedPointer = dynamic_cast<Derived*>(basePointer.get());

// If they are not polymorphic types only need a pointer to the derived type use static_cast and hope for the best:
Derived *derivedPointer = static_cast<Derived*>(basePointer.get());

// If you need to convert a unique_ptr containing a polymorphic type:
// (You can also use static_cast if you know it will cast correctly; test for nullptr would not be needed.)
Derived *tmp = dynamic_cast<Derived*>(basePointer.get());
std::unique_ptr<Derived> derivedPointer;
if(tmp != nullptr)
{
    basePointer.release();
    derivedPointer.reset(tmp);
}

// If you need to convert unique_ptr containing a non-polymorphic type:
std::unique_ptr<Derived>
    derivedPointer(static_cast<Derived*>(basePointer.release()));