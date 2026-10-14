import { cn } from '../../utils/cn.js';

export default function Button({ className, variant = 'primary', size = 'md', ...props }) {
  const base =
    'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-60 ring-offset-background';

  const variants = {
    primary: 'bg-sky-600 text-white hover:bg-sky-700 shadow-sm',
    outline: 'border bg-background hover:bg-accent hover:text-accent-foreground',
    ghost: 'hover:bg-accent hover:text-accent-foreground',
    destructive: 'bg-red-600 text-white hover:bg-red-700',
  };

  const sizes = {
    sm: 'h-8 px-2',
    md: 'h-9 px-3',
    lg: 'h-10 px-4',
  };

  return (
    <button
      className={cn(base, variants[variant] ?? variants.primary, sizes[size] ?? sizes.md, className)}
      type={props.type ?? 'button'}
      {...props}
    />
  );
}
