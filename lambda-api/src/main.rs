use tracing_subscriber::filter::{EnvFilter, LevelFilter};use lambda_http::{run, service_fn, Body, Error, Request, RequestExt, Response};

/// Handles an AWS Lambda HTTP request asynchronously.
///
/// # Arguments
///
/// * `event` - The incoming HTTP request event.
///
/// # Returns
///
/// Returns a `Result` containing the HTTP response or an error.
///
/// # Examples
///
/// ```rust
/// use lambda_http::{Request, Body, Response};
/// use lambda_http::http::Method;
/// use std::convert::Infallible;
///
/// async fn handle_request(event: Request) -> Result<Response<Body>, Infallible> {
///     // Handle the HTTP request here
///     unimplemented!();
/// }
/// ```
async fn handler(event: Request) -> Result<Response<Body>, Error> {
    // Extract some useful information from the request
    let who = event
        .query_string_parameters_ref()
        .and_then(|params| params.first("name"))
        .unwrap_or("world");
    let message = format!("Hello {who}, this is an AWS Lambda HTTP request");

    // Return something that implements IntoResponse.
    // It will be serialized to the right response event automatically by the runtime
    let resp = Response::builder()
        .status(200)
        .header("content-type", "text/html")
        .body(message.into())
        .map_err(Box::new)?;
    Ok(resp)
}

/// Initializes and runs the AWS Lambda HTTP handler.
///
/// # Returns
///
/// Returns a `Result` indicating success or failure.
///
/// # Errors
///
/// This function returns an error if there is an issue initializing the tracing subscriber or
/// running the Lambda handler.
///
/// # Examples
///
/// ```rust
/// use lambda_http::Error;
///
/// #[tokio::main]
/// async fn main() -> Result<(), Error> {
///     lambda_http_rust::run_lambda().await
/// }
/// ```
#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::builder()
                .with_default_directive(LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        // disable printing the name of the module in every log line.
        .with_target(false)
        // disabling time is handy because CloudWatch will add the ingestion time.
        .without_time()
        .init();

    run(service_fn(handler)).await
}
