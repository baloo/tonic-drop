use tonic::{transport::Server, Request, Response, Status};

mod hellodrop {
    tonic::include_proto!("grpc.helloworld");
}
use hellodrop::{
    hello_world_server::{HelloWorld, HelloWorldServer},
    Ping, Pong,
};

struct Service {}

impl Drop for Service {
    fn drop(&mut self) {
        eprintln!("drop never called");
    }
}

#[tonic::async_trait]
impl HelloWorld for Service {
    async fn hello(&self, request: Request<Ping>) -> Result<Response<Pong>, Status> {
        Ok(Response::new(Pong {
            world: String::from("pong"),
        }))
    }
}

async fn server() -> Result<(), Box<dyn std::error::Error>> {
    let service = Service {};
    let addr = "[::]:1235".parse().unwrap();

    Server::builder()
        .add_service(HelloWorldServer::new(service))
        .serve(addr)
        .await
        .map(|e| {
            eprintln!("tonic exit:{:?}", e);
            e
        })
        .map_err(|e| {
            eprintln!("tonic error:{}", e);
            e
        })?;

    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    server().await;

    Ok(())
}
