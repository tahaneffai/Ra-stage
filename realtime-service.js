const { Server } = require('socket.io');
const { pool } = require('./db');

class RealtimeService {
  constructor(server) {
    this.io = new Server(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });
    
    this.connectedClients = new Map();
    this.trainUpdates = new Map();
    
    this.setupSocketHandlers();
    this.startRealTimeUpdates();
  }

  setupSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`🔌 Client connected: ${socket.id}`);
      
      // Store client info
      this.connectedClients.set(socket.id, {
        id: socket.id,
        connectedAt: new Date(),
        subscriptions: new Set()
      });

      // Handle client joining specific station rooms
      socket.on('join-station', (stationId) => {
        socket.join(`station-${stationId}`);
        this.connectedClients.get(socket.id).subscriptions.add(stationId);
        console.log(`🚉 Client ${socket.id} joined station ${stationId}`);
      });

      // Handle client leaving station rooms
      socket.on('leave-station', (stationId) => {
        socket.leave(`station-${stationId}`);
        this.connectedClients.get(socket.id).subscriptions.delete(stationId);
        console.log(`🚉 Client ${socket.id} left station ${stationId}`);
      });

      // Handle real-time train tracking subscription
      socket.on('track-train', (trainId) => {
        socket.join(`train-${trainId}`);
        console.log(`🚂 Client ${socket.id} tracking train ${trainId}`);
      });

      // Handle client disconnect
      socket.on('disconnect', () => {
        console.log(`🔌 Client disconnected: ${socket.id}`);
        this.connectedClients.delete(socket.id);
      });

      // Handle custom events from clients
      socket.on('request-station-updates', (stationId) => {
        this.sendStationUpdates(socket, stationId);
      });

      socket.on('request-train-status', (trainId) => {
        this.sendTrainStatus(socket, trainId);
      });
    });
  }

  // Send real-time updates to all clients
  broadcastUpdate(event, data) {
    this.io.emit(event, {
      timestamp: new Date().toISOString(),
      data: data
    });
  }

  // Send updates to specific station subscribers
  broadcastToStation(stationId, event, data) {
    this.io.to(`station-${stationId}`).emit(event, {
      timestamp: new Date().toISOString(),
      stationId: stationId,
      data: data
    });
  }

  // Send updates to specific train trackers
  broadcastToTrain(trainId, event, data) {
    this.io.to(`train-${trainId}`).emit(event, {
      timestamp: new Date().toISOString(),
      trainId: trainId,
      data: data
    });
  }

  // Simulate real-time train updates
  async startRealTimeUpdates() {
    setInterval(async () => {
      try {
        // Simulate train movements and delays
        await this.simulateTrainUpdates();
        
        // Send system heartbeat
        this.broadcastUpdate('system-heartbeat', {
          status: 'operational',
          timestamp: new Date().toISOString()
        });
        
      } catch (error) {
        console.error('❌ Error in real-time updates:', error);
      }
    }, 10000); // Update every 10 seconds
  }

  // Simulate realistic train updates
  async simulateTrainUpdates() {
    try {
      // Get all stations for simulation
      const result = await pool.query('SELECT id, nom, ville FROM gares ORDER BY id');
      const stations = result.rows;

      // Simulate random train movements between stations
      stations.forEach((station, index) => {
        if (index < stations.length - 1) {
          const nextStation = stations[index + 1];
          
          // Simulate train arrival/departure
          const trainUpdate = {
            trainId: `T${station.id}${nextStation.id}`,
            currentStation: station,
            nextStation: nextStation,
            status: this.getRandomTrainStatus(),
            estimatedArrival: this.getRandomArrivalTime(),
            delay: this.getRandomDelay(),
            platform: this.getRandomPlatform(),
            passengers: this.getRandomPassengerCount()
          };

          // Store update
          this.trainUpdates.set(trainUpdate.trainId, trainUpdate);

          // Broadcast to station subscribers
          this.broadcastToStation(station.id, 'train-update', trainUpdate);
          this.broadcastToStation(nextStation.id, 'train-update', trainUpdate);
          
          // Broadcast to train trackers
          this.broadcastToTrain(trainUpdate.trainId, 'train-status', trainUpdate);
        }
      });

      // Broadcast general system update
      this.broadcastUpdate('system-update', {
        activeTrains: this.trainUpdates.size,
        totalStations: stations.length,
        lastUpdate: new Date().toISOString()
      });

    } catch (error) {
      console.error('❌ Error simulating train updates:', error);
    }
  }

  // Helper methods for realistic simulation
  getRandomTrainStatus() {
    const statuses = ['on-time', 'delayed', 'arriving', 'departing', 'boarding'];
    return statuses[Math.floor(Math.random() * statuses.length)];
  }

  getRandomArrivalTime() {
    const now = new Date();
    const minutes = Math.floor(Math.random() * 30) + 1; // 1-30 minutes
    return new Date(now.getTime() + minutes * 60000);
  }

  getRandomDelay() {
    const delays = [0, 2, 5, 8, 12, 15];
    return delays[Math.floor(Math.random() * delays.length)];
  }

  getRandomPlatform() {
    return Math.floor(Math.random() * 4) + 1; // Platforms 1-4
  }

  getRandomPassengerCount() {
    return Math.floor(Math.random() * 200) + 50; // 50-250 passengers
  }

  // Send station-specific updates
  async sendStationUpdates(socket, stationId) {
    try {
      const result = await pool.query('SELECT * FROM gares WHERE id = $1', [stationId]);
      if (result.rows.length > 0) {
        const station = result.rows[0];
        
        // Get active trains for this station
        const activeTrains = Array.from(this.trainUpdates.values())
          .filter(train => 
            train.currentStation.id === stationId || 
            train.nextStation.id === stationId
          );

        socket.emit('station-updates', {
          station: station,
          activeTrains: activeTrains,
          timestamp: new Date().toISOString()
        });
      }
    } catch (error) {
      console.error('❌ Error sending station updates:', error);
    }
  }

  // Send train-specific status
  async sendTrainStatus(socket, trainId) {
    const trainUpdate = this.trainUpdates.get(trainId);
    if (trainUpdate) {
      socket.emit('train-status', trainUpdate);
    } else {
      socket.emit('train-not-found', { trainId, message: 'Train not found' });
    }
  }

  // Manual trigger for real-time updates (for testing)
  triggerManualUpdate(type, data) {
    switch (type) {
      case 'station':
        this.broadcastToStation(data.stationId, 'manual-update', data);
        break;
      case 'train':
        this.broadcastToTrain(data.trainId, 'manual-update', data);
        break;
      case 'system':
        this.broadcastUpdate('manual-update', data);
        break;
      default:
        this.broadcastUpdate('manual-update', data);
    }
  }

  // Get connection statistics
  getConnectionStats() {
    return {
      totalConnections: this.connectedClients.size,
      activeSubscriptions: Array.from(this.connectedClients.values())
        .reduce((total, client) => total + client.subscriptions.size, 0),
      activeTrains: this.trainUpdates.size,
      timestamp: new Date().toISOString()
    };
  }
}

module.exports = RealtimeService;


