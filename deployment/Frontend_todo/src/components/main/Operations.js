import '../../index.css';
import Task from './Task';
import {useState, useEffect} from 'react';
import UpperOperations from './UpperOperations';
import TodoService from '../../service/TodoService';


function Operations() {

  const [ alltask, setAllTask ] = useState([])

  useEffect(() => {
      TodoService.getAllTasks()
      .then((tasks) => {
        setAllTask(tasks.data);
        console.log(tasks.data);
      })
      .catch((error) => {
        console.error(error);
      });
    }, []);

  return (
    <>
    <UpperOperations alltask={alltask} setAllTask={setAllTask} />
    <Task  alltask={alltask} setAllTask={setAllTask} />
    </>
  );
}

export default Operations;