use executionhandler::ExecutionHandler;

#[tokio::test]
async fn test_new_architecture_basic() {
    let handler = ExecutionHandler::new().await;
    assert!(handler.list_exchanges().await.is_empty());
}

#[test]
fn test_exchange_factory() {
    let supported = ExecutionHandler::supported_exchanges();
    assert!(supported.contains(&"kraken"));
    assert_eq!(supported, vec!["kraken"]);
}

#[test]
#[ignore = "requires KRAKEN_API_KEY and KRAKEN_SECRET_KEY environment variables"]
fn test_exchange_config_templates() {
    let kraken_config = ExecutionHandler::create_exchange_config("kraken");
    assert!(kraken_config.is_ok());
    
    let invalid_config = ExecutionHandler::create_exchange_config("invalid");
    assert!(invalid_config.is_err());
}
