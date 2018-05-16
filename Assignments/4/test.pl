at(Mat, Row, Col, Val) :- nth1(Row, Mat, ARow), nth1(Col, ARow, Val).

test :- map(_, Map), at(Map, 2, 1, Val), write(Val).
