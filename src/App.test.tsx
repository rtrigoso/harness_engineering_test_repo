import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import App from './App'

describe('App counter', () => {
  it('starts at 0', () => {
    render(<App />)
    expect(screen.getByRole('button', { name: /count is 0/i })).toBeInTheDocument()
  })

  it('increments on each click', () => {
    render(<App />)
    const button = screen.getByRole('button', { name: /count is/i })

    fireEvent.click(button)
    expect(button).toHaveTextContent('Count is 1')

    fireEvent.click(button)
    expect(button).toHaveTextContent('Count is 2')
  })
})
