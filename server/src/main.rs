use axum::{extract::State, response::Html, routing::get, Router};
use std::{net::SocketAddr, ops::Deref, str::FromStr, sync::Arc};
use tower_http::services::ServeDir;

use yew::ServerRenderer;

use tracing::Level;
use tracing_subscriber::{filter::Targets, layer::SubscriberExt, util::SubscriberInitExt};

use frontend::App;

const INDEX_SOURCE: &str = include_str!("../../dist/index.html");

#[derive(Clone, Debug)]
struct AppState {
    index_html_before: Arc<String>,
    index_html_after: Arc<String>,
}

impl Default for AppState {
    fn default() -> Self {
        let (index_html_before, index_html_after) = INDEX_SOURCE.split_once("<body>").unwrap();

        AppState {
            index_html_before: Arc::new(index_html_before.to_owned()),
            index_html_after: Arc::new(index_html_after.to_owned()),
        }
    }
}

#[tokio::main]
async fn main() {
    let filter = Targets::from_str(std::env::var("RUST_LOG").as_deref().unwrap_or("info"))
        .expect("RUST_LOG should be a valid tracing filter");
    tracing_subscriber::fmt()
        .with_max_level(Level::TRACE)
        .finish()
        .with(filter)
        .init();

    tracing::info!("starting up");

    let app_state = AppState::default();

    let app = Router::new()
        .route("/", get(root_get))
        .nest_service("/static", ServeDir::new("dist"))
        .with_state(app_state);
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));

    tracing::info!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .expect("Failed to run server")
}

#[tracing::instrument]
async fn root_get(State(state): State<AppState>) -> Html<String> {
    let mut index = String::from(state.index_html_before.deref());
    index.push_str("<body>");

    // You are supposed to recrate this every time
    let renderer = ServerRenderer::<App>::new();

    index.push_str(&renderer.render().await);
    index.push_str(&state.index_html_after);

    index.into()
}
