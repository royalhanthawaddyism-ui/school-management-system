// @ts-nocheck
/// <reference lib="deno.ns" />
import { serve } from 'https://deno.land/std@0.203.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.10.0?target=deno';

serve(async (req: Request) => {
  try {
    const body = await req.json();

    const user_id = typeof body['user_id'] === 'string' ? body['user_id'] : '';
    const email = typeof body['email'] === 'string' ? body['email'] : '';
    const password = typeof body['password'] === 'string' ? body['password'] : '';
    const role = typeof body['role'] === 'string' ? body['role'] : '';

    if (!user_id || !email || !role) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields.' }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      return new Response(
        JSON.stringify({ error: 'Missing environment variables.' }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      auth: { persistSession: false },
    });

    // =========================
    // 1. Update Auth user
    // =========================
    const authUpdate: any = {
      email,
    };

    // password မရှိရင် update မလုပ်
    if (password && password.trim() !== '') {
      authUpdate.password = password;
    }

    const { error: authError } =
      await supabase.auth.admin.updateUserById(user_id, authUpdate);

    if (authError) {
      return new Response(
        JSON.stringify({ error: authError.message }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

    // =========================
    // 2. Update profile table
    // =========================
    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        email,
        role: role,
      })
      .eq('id', user_id);

    if (profileError) {
      return new Response(
        JSON.stringify({ error: profileError.message }),
        {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        user_id,
        email,
        role,
      }),
      {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    );
  }
});