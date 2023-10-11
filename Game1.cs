using Assimp;
using Liru3D.Animations;
using Liru3D.Models;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using System;
using System.Diagnostics;
using System.Linq;
using static System.Net.Mime.MediaTypeNames;
using PrimitiveType = Microsoft.Xna.Framework.Graphics.PrimitiveType;

namespace NOOOOWYYYY
{
    public class Game1 : Game
    {
        private GraphicsDeviceManager _graphics;
        private SpriteBatch _spriteBatch;
        
        Matrix view;
        Matrix projection;
        Matrix world;
        Vector3 cameraPosition = new Vector3(0, -10, 10);
        Vector3 cameraTarget = new Vector3(0, 0, 0);
        float angle = 0;
        SkinnedModel characterModel;
        AnimationPlayer animationPlayer;
        private Texture2D texture;
        Effect effect1;

        public Game1()
        {
            _graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
            IsMouseVisible = true;
        }

        protected override void Initialize()
        {
            // TODO: Add your initialization logic here
            world = Matrix.CreateWorld(Vector3.Zero, Vector3.Forward, Vector3.Up);
            view = Matrix.CreateLookAt(new Vector3(0, 10, 10), new Vector3(0, 0, 0), Vector3.UnitY);
            projection = Matrix.CreatePerspectiveFieldOfView(MathHelper.ToRadians(45), 800 / 480f, 0.1f, 10000f);
            

            base.Initialize();
        }

        protected override void LoadContent()
        {
            characterModel = Content.Load<SkinnedModel>("miseksport77");
            texture = Content.Load<Texture2D>("tekstura");

            effect1 = Content.Load<Effect>("toonik");
            animationPlayer = new AnimationPlayer(characterModel);
            animationPlayer.Animation = characterModel.Animations[0];
            animationPlayer.PlaybackSpeed = 1f;
            animationPlayer.IsLooping = true;
            animationPlayer.IsPlaying = true;
            animationPlayer.CurrentTick = characterModel.Animations[0].DurationInTicks;
        }

        protected override void Update(GameTime gameTime)
        {
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.Escape))
                Exit();

            animationPlayer.Update(gameTime);

            KeyboardState keyboardState = Keyboard.GetState();


            float cameraSpeed = 100f;

            if (keyboardState.IsKeyDown(Keys.Left))
            {
                cameraPosition.X -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.X -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.Right))
            {
                cameraPosition.X += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.X += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.Up))
            {
                cameraPosition.Y += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.Y += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.Down))
            {
                cameraPosition.Y -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.Y -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.Space))
            {
                cameraPosition.Z += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.Z += cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.LeftControl))
            {
                cameraPosition.Z -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
                cameraTarget.Z -= cameraSpeed * (float)gameTime.ElapsedGameTime.TotalSeconds;
            }
            if (keyboardState.IsKeyDown(Keys.P))
            {
                angle += 1;
            }

            view = Matrix.CreateLookAt(cameraPosition, cameraTarget, Vector3.Up);


            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.CornflowerBlue);
            moreDraw();
            base.Draw(gameTime);
        }


        public void moreDraw()
        {
            Matrix[] boneTransforms = (Matrix[])animationPlayer.BoneSpaceTransforms;

            foreach (SkinnedMesh mesh in characterModel.Meshes)
            {
                effect1.CurrentTechnique = effect1.Techniques["Toon"];

                effect1.Parameters["Bones"].SetValue(boneTransforms);
                effect1.Parameters["World"].SetValue(world *Matrix.CreateTranslation(new Vector3(0,0,0))* Matrix.CreateRotationX(0.5f) * Matrix.CreateRotationY(angle));
                effect1.Parameters["View"].SetValue(view);
                effect1.Parameters["Projection"].SetValue(projection);
                effect1.Parameters["WorldInverseTranspose"].SetValue(Matrix.Transpose(Matrix.Invert(world)));
                effect1.Parameters["DiffuseLightDirection"].SetValue(new Vector3(0,1,1));
                effect1.Parameters["DiffuseColor"].SetValue(Color.White.ToVector4());
                effect1.Parameters["DiffuseIntensity"].SetValue(1);
                effect1.Parameters["LineColor"].SetValue(Color.Black.ToVector4());
                effect1.Parameters["LineThickness"].SetValue(new Vector4(1f));
                effect1.Parameters["Texture"].SetValue(texture);

                foreach (var pass in effect1.CurrentTechnique.Passes)
                {
                    pass.Apply();
                    effect1.GraphicsDevice.SetVertexBuffer(mesh.VertexBuffer);
                    effect1.GraphicsDevice.Indices = mesh.IndexBuffer;
                    effect1.GraphicsDevice.DrawIndexedPrimitives(PrimitiveType.TriangleList, 0, 0, mesh.VertexBuffer.VertexCount);

                }


            }
        }

    }
}