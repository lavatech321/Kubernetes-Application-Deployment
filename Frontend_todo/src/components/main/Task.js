import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import TodoService from '../../service/TodoService';
import { format } from 'date-fns';

function formatDate(dateString) {
  return format(new Date(dateString), "eee, dd yyyy"); // "Tue, 12 2024"
}

function Task({alltask, setAllTask}) {

  const handleStatus = (e, id) => {
    const isChecked = e.target.checked; // Get the checkbox status (true/false)

    TodoService.getTask(id) // Fetch the task details from the backend
        .then((response) => {
            const task = response.data; // Extract the task data
            const updatedTask = { ...task, status: isChecked }; // Update only the 'status' field

            TodoService.updateTask(id, updatedTask) // Send the updated task to the backend
                .then((updateResponse) => {
                    console.log("Task status updated successfully:", updateResponse.data);
                    setAllTask(alltask.map(t => t.id === id ? updatedTask : t));
                    // Optionally, update the state or UI if needed
                })
                .catch((error) => {
                    console.error("Error updating task status:", error);
                });
        })
        .catch((error) => {
            console.error("Error fetching task details:", error);
        });
};


  const deleteTask = (id) => {

    TodoService.deleteTask(id)
    .then(() => {
      setAllTask(prevTask => prevTask.filter(task => task.id !== id)  );

    })
    .catch((error) => {
      console.error(error);
    });
  }

  const viewAll = () => {
    TodoService.getAllTasks()
    .then((response) => {
      setAllTask(response.data);
    })
    .catch((error) => {
      console.error(error);
    });
  }

  const viewPending = () => {
    TodoService.getAllPending()
    .then((response) => {
      setAllTask(response.data);
    })
    .catch((error) => {
      console.error(error);
    });
  }

  const viewCompleted = () => {
    TodoService.getAllCompleted()
    .then((response) => {
      setAllTask(response.data);
    })
    .catch((error) => {
      console.error(error);
    });
  }

  return (
    <>
    <Container className="mt-5 bg-light">

      <div className="d-flex justify-content-between align-items-center py-2 border-bottom">
      <h3 className="text-center pt-3">Tasks</h3>
      <div>
      <Button type="submit" className="btn btn-primary" onClick={() => viewAll()}>
            View All
        </Button>
      <Button type="submit" className="btn btn-primary mx-3" onClick={() => viewPending()}>
            View Pending
        </Button>
        <Button type="submit" className="btn btn-primary" onClick={() => viewCompleted()}>
            View Completed
        </Button>
      </div>
      </div>
        {
          alltask.map(
            (task) =>
              <Row className="py-2 align-items-center border-bottom">
              <Col className="text-start">
                <Form.Group className="mb-3" controlId="formBasicCheckbox">
                  <Form.Check type="checkbox" label={task.task} checked={task.status}
                  onChange={(e) => handleStatus(e,task.id)} />
                </Form.Group>
              </Col>
              <Col className="text-center">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="mx-2 bi bi-clock" viewBox="0 0 16 16">
                      <path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71z"/>
                      <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16m7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0"/>
                    </svg>
                    {formatDate(task.task_date)}
              </Col>
            <Col className="text-end">
            <Button type="submit" className="btn btn-warning" onClick={() => deleteTask(task.id)}>
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-trash" viewBox="0 0 16 16">
                <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5m2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5m3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0z"/>
                <path d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1zM4.118 4 4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4zM2.5 3h11V2h-11z"/>
                </svg>
            </Button>
            </Col>
          </Row>
        )}

    </Container>

    </>
  );
}

export default Task;