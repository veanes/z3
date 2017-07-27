/*
  Copyright (c) 2017 Microsoft Corporation
  Author: Lev Nachmanson
*/

#pragma once
// add to value the stack semantics
#include <stack>
namespace lp {
template <typename T> class stacked_value {
    T m_value;    
    std::stack<T> m_stack;
public:
    void push() {
        m_stack.push(m_value);
    }

    unsigned stack_size() const {
        return static_cast<unsigned>(m_stack.size());
    }

    void pop() {
        pop(1);
    }
    void pop(unsigned k) {
        while (k-- > 0) {
            if (m_stack.empty())
                return;
            m_value = m_stack.top();
            m_stack.pop();
        }
    }

    stacked_value() {}
    stacked_value(const T& m) {
        m_value = m;
    }
    stacked_value(const T&& m) {
        m_value = std::move(m);
    }
    
    T& operator=(T arg) { // copy/move constructor
        m_value = arg;
        return m_value;
    }

    operator T&() {
        return m_value;
    }
    
    operator const T&() const {
        return m_value;
    }

    T & operator()() {
        return m_value;
    }

    const T & operator()() const {
        return m_value;
    }


};
}
