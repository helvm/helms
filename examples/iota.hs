iota' :: ((t1 -> t2 -> t1)
          -> ((t5 -> t4 -> t3) -> (t5 -> t4) -> t5 -> t3)
          -> (t6 -> t7 -> t6)
          -> t)
         -> t
iota' x = x k s k 
    where k x y = x
          s x y z = x z (y z)

fix :: (a -> a) -> a
fix f = let result = f result in result

newtype D = In { out :: D -> D }

iota :: D
iota = In $ \x -> out (out x s) k
    where k = In $ \x -> In $ const x
          s = In $ \x -> In $ \y -> In $ \z -> out (out x z) (out y z)
