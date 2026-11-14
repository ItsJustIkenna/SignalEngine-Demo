//! Fresh in-repo subscriber for standalone demo builds.

#[derive(Debug, thiserror::Error)]
pub enum SubscriberError {
    #[error("subscriber error: {0}")]
    Message(String),
}

#[derive(Debug, Clone)]
pub struct ConnectionConfig {
    pub address: String,
}

impl ConnectionConfig {
    pub fn new(addr: impl Into<String>) -> Self {
        Self {
            address: addr.into(),
        }
    }
}

#[derive(Debug, Clone, Default)]
pub struct HealthMetrics {
    connected: bool,
    error_count: u64,
}

impl HealthMetrics {
    pub fn get_connected(&self) -> bool {
        self.connected
    }
    pub fn get_error_count(&self) -> u64 {
        self.error_count
    }
}

#[derive(Debug, Clone)]
pub struct BrokerMessage {
    timestamp: u64,
    data: Vec<u8>,
}

impl BrokerMessage {
    pub fn get_timestamp(&self) -> u64 {
        self.timestamp
    }
    pub fn get_data(&self) -> &[u8] {
        &self.data
    }
}

#[derive(Debug, Clone)]
pub struct Subscriber {
    topics: Vec<String>,
    started: bool,
}

impl Subscriber {
    pub fn new(config: ConnectionConfig, topics: &[&str]) -> Result<Self, SubscriberError> {
        let _ = config;
        Ok(Self {
            topics: topics.iter().map(|s| s.to_string()).collect(),
            started: false,
        })
    }

    pub fn start(&mut self) -> Result<(), SubscriberError> {
        self.started = true;
        Ok(())
    }

    pub fn poll_all_messages(&self, _max: usize) -> Vec<(usize, BrokerMessage)> {
        Vec::new()
    }

    pub fn get_topic_name(&self, topic_idx: usize) -> Option<String> {
        self.topics.get(topic_idx).cloned()
    }

    pub fn get_health_metrics(&self) -> Result<HealthMetrics, SubscriberError> {
        Ok(HealthMetrics {
            connected: self.started,
            error_count: 0,
        })
    }

    pub fn is_stale(&self, _idle_ms: u64) -> bool {
        false
    }

    pub fn reconnect(&mut self) -> Result<(), SubscriberError> {
        self.started = true;
        Ok(())
    }
}
